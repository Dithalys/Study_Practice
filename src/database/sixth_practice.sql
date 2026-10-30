INSERT INTO Event_types (id, title)
SELECT 
    i,
    CASE (i % 5)
        WHEN 0 THEN 'Банкет №' || i
        WHEN 1 THEN 'Конференция №' || i
        WHEN 2 THEN 'Свадьба №' || i
        WHEN 3 THEN 'Корпоратив №' || i
        ELSE 'Выставка №' || i
    END
FROM generate_series(1, 100) AS i
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS Clients (id SERIAL PRIMARY KEY, name TEXT, email TEXT);

INSERT INTO Clients (id, name, email)
SELECT 
    i,
    'Клиент ' || chr(65 + (i % 26)) || i,
    'client_' || i || '@example.com'
FROM generate_series(1, 100) AS i
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS Managers (id SERIAL PRIMARY KEY, name TEXT, department TEXT);

INSERT INTO Managers (id, name, department)
SELECT 
    i,
    'Менеджер ' || chr(65 + (i % 26)) || i,
    CASE (i % 3) WHEN 0 THEN 'VIP' WHEN 1 THEN 'Масс-маркет' ELSE 'Регионы' END
FROM generate_series(1, 100) AS i
ON CONFLICT (id) DO NOTHING;

INSERT INTO Events (
    id, title, description, people_count, date_start, date_end, 
    map_point, budget, manager_id, client_id, type_id, status_id
)
SELECT 
    i,
    'Мероприятие №' || i,
    'Описание для масштабного события под номером ' || i,
    (random() * 500 + 10)::INT,
    NOW() + (i || ' hours')::INTERVAL, 
    NOW() + ((i + 4) || ' hours')::INTERVAL, 
    'Координаты ' || (random()*100)::NUMERIC(4,2) || ', ' || (random()*100)::NUMERIC(4,2),
    (random() * 490000 + 10000)::NUMERIC(10,2), 
    (random() * 99 + 1)::INT, 
    (random() * 99 + 1)::INT, 
    (random() * 99 + 1)::INT, 
    (random() * 4 + 1)::INT 
FROM generate_series(1, 1000) AS i
ON CONFLICT (id) DO NOTHING;

ANALYZE Events;
ANALYZE Event_types;
ANALYZE Clients;
ANALYZE Managers;

CREATE INDEX idx_events_people_count ON Events(people_count);
CREATE INDEX idx_events_manager_budget ON Events(manager_id, budget);
CREATE INDEX idx_events_heavy_budget ON Events(budget) WHERE budget > 400000.00;

EXPLAIN ANALYZE 
SELECT * FROM Events WHERE status_id = 1; 
EXPLAIN ANALYZE 
SELECT id, title, people_count FROM Events WHERE people_count = 250;
EXPLAIN ANALYZE 
SELECT * FROM Events WHERE manager_id = 42 AND budget < 50000.00;
EXPLAIN ANALYZE 
SELECT id, budget FROM Events WHERE budget = 450000.00;
EXPLAIN ANALYZE 
SELECT id, people_count FROM Events ORDER BY people_count DESC LIMIT 10;
