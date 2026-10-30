CREATE ROLE db_admin_group;
CREATE ROLE db_manager_group;
CREATE ROLE db_analyst_group;


ALTER DATABASE current_db_name OWNER TO db_admin_group;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_admin_group;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO db_admin_group;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO db_admin_group;

GRANT USAGE ON SCHEMA public TO db_manager_group;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Events, Event_types TO db_manager_group;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO db_manager_group;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_manager_group;

GRANT USAGE ON SCHEMA public TO db_analyst_group;
GRANT SELECT ON TABLE Events TO db_analyst_group;


CREATE ROLE admin_user WITH LOGIN PASSWORD 'AdminSecurePass2026';
GRANT db_admin_group TO admin_user;
CREATE ROLE manager_user WITH LOGIN PASSWORD 'ManagerPass2026';
GRANT db_manager_group TO manager_user;
CREATE ROLE analyst_user WITH LOGIN PASSWORD 'AnalystPass2026';
GRANT db_analyst_group TO analyst_user;


SET ROLE admin_user;
BEGIN;
CREATE TABLE IF NOT EXISTS System_Audit_Logs (
    id SERIAL PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO System_Audit_Logs (action_type) VALUES ('Инициализация аудита ролей');
COMMIT;

RESET ROLE;

SET ROLE manager_user;
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
DO $$ 
DECLARE 
    v_event_id INT := 1; 
    v_menu_cost NUMERIC(10,2); 
    v_event_budget NUMERIC(10,2); 
BEGIN 
    v_menu_cost := get_event_menu_cost(v_event_id); 
    SELECT budget INTO v_event_budget FROM Events WHERE id = v_event_id; 
    IF v_menu_cost > v_event_budget THEN 
        RAISE EXCEPTION 'Критическая ошибка: Стоимость меню (%) превышает бюджет (%)', v_menu_cost, v_event_budget; 
    ELSE 
        UPDATE Events SET status_id = 3 WHERE id = v_event_id; 
    END IF; 
END $$;
COMMIT;

RESET ROLE;

SET ROLE analyst_user;
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(id) as total_events, SUM(budget) as total_revenue, AVG(budget) as avg_budget 
FROM Events;
COMMIT;

RESET ROLE;
