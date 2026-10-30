BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
DO $$
DECLARE
    v_event_id INT := 1;
    v_menu_cost NUMERIC(10,2);
    v_event_budget NUMERIC(10,2);
BEGIN
    v_cost := get_event_menu_cost(v_event_id);
    
    SELECT budget INTO v_event_budget FROM Events WHERE id = v_event_id;
    
    IF v_menu_cost > v_event_budget THEN
        RAISE EXCEPTION 'Критическая ошибка: Стоимость меню (%) превышает бюджет (%)', 
            v_menu_cost, v_event_budget;
    ELSE
        UPDATE Events SET status_id = 3 WHERE id = v_event_id;
    END IF;
END $$;
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT et.title, SUM(e.people_count) as total_guests
FROM Events e
JOIN Event_types et ON e.type_id = et.id
GROUP BY et.title;
SELECT 
    COUNT(id) as total_events,
    SUM(budget) as total_revenue,
    AVG(budget) as avg_budget
FROM Events;
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(budget) FROM Events; 
INSERT INTO Events(title, description, people_count, date_start, date_end, map_point, budget, manager_id, client_id, type_id, status_id)
VALUES ('Конкурентный Банкет', 'Тест ошибки', 50, '2026-11-01 12:00:00', '2026-11-01 18:00:00', 'Координаты', 60000.00, 3, 8, 1, 1);
COMMIT;


BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE Events SET status_id = 3 WHERE id = 1 AND budget >= get_event_menu_cost(1);
COMMIT;

BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*), SUM(budget) FROM Events;
SELECT * FROM analytics.event_status_logs;
COMMIT;

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
COMMIT;
