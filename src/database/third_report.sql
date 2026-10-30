CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS hr;

CREATE OR REPLACE FUNCTION get_event_menu_cost(p_event_id INT)
RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_total_cost NUMERIC(10,2);
BEGIN
    SELECT COALESCE(SUM(em.quantity * p.price), 0)
    INTO v_total_cost
    FROM Event_menu em
    JOIN Products p ON em.product_id = p.id
    WHERE em.event_id = p_event_id;

    RETURN v_total_cost;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_product_ingredients_stock(p_product_id INT)
RETURNS TEXT AS $$
DECLARE
    v_shortage_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_shortage_count
    FROM Product_compound pc
    JOIN Ingredients i ON pc.ingredients_id = i.id
    WHERE pc.product_id = p_product_id AND i.quantity < pc.quantity;

    IF v_shortage_count > 0 THEN
        RETURN 'Недостаточно ингредиентов на складе';
    ELSE
        RETURN 'В наличии';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE hr.register_event_payment(
    p_event_id INT,
    p_client_id INT,
    p_amount NUMERIC(10,2),
    p_payment_type_id INT
)
AS $$
BEGIN
    INSERT INTO Event_payments(amount, event_id, client_id, payment_type_id)
    VALUES (p_amount, p_event_id, p_client_id, p_payment_type_id);

    UPDATE Events
    SET budget = budget + p_amount
    WHERE id = p_event_id;
    
    COMMIT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE close_event_and_spend_ingredients(p_event_id INT)
AS $$
BEGIN
    UPDATE Ingredients i
    SET quantity = i.quantity - (em.quantity * pc.quantity)
    FROM Event_menu em
    JOIN Product_compound pc ON em.product_id = pc.product_id
    WHERE em.event_id = p_event_id AND pc.ingredients_id = i.id;

    UPDATE Events
    SET status_id = 4
    WHERE id = p_event_id;

    COMMIT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_event_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date_end <= NEW.date_start THEN
        RAISE EXCEPTION 'Дата окончания мероприятия (%) не может быть раньше или равна дате начала (%)', 
            NEW.date_end, NEW.date_start;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_event_save
BEFORE INSERT OR UPDATE ON Events
FOR EACH ROW
EXECUTE FUNCTION validate_event_dates();

CREATE TABLE IF NOT EXISTS analytics.event_status_logs (
    id SERIAL PRIMARY KEY,
    event_id INT,
    old_status_id INT,
    new_status_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_event_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.status_id IS DISTINCT FROM NEW.status_id) THEN
        INSERT INTO analytics.event_status_logs(event_id, old_status_id, new_status_id)
        VALUES (NEW.id, OLD.status_id, NEW.status_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_event_status_update
AFTER UPDATE ON Events
FOR EACH ROW
EXECUTE FUNCTION log_event_status_change();