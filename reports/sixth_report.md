# 🏛️ Практика №6: Работа с индексами

**Дисциплина:** [Клиент-серверные системы управления базами данных](../README.md)  
**Запросы:** [sixth_practice.sql](../src/database/sixth_practice.sql)  
**Предыдущая работа:** [Практика №5: Работа с группами ролей и ролями](./fifth_report.md)
**Следующая работа:** [Практика №7: Резервное копирование базы данных](./seventh_report.md)

> 💡 *Примечание: Все имена, персонажи и данные в настоящей работе являются вымышленными. Любое совпадение с реальными людьми случайно.*

---

## 🎯 Техническое задание

Заполнить [реализованной базе данных](./second_report.md) таблицы случайными данными (по 100 кортежей минимум) с использованием функций-генераторов и добавить к этим данным индексы, многоколоночные индексы и частичные индексы. Провести индексное сканирование, последовательное сканирование и сортировку таблиц с индексами

---

## 📥 DML: запросы

### 1. Заполнение таблиц случайными данными

```sql
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
```

### 2. Создание индексов различных типов

```sql
CREATE INDEX idx_events_people_count ON Events(people_count);
CREATE INDEX idx_events_manager_budget ON Events(manager_id, budget);
CREATE INDEX idx_events_heavy_budget ON Events(budget) WHERE budget > 400000.00;
```

### 3. Демонстрация

```sql
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
```

---

## 📝 Заключение

В ходе выполнения практической работы были успешно освоены методы генерации тестовых демонстрационных данных и инструменты оптимизации производительности реляционных баз данных.

Были достигнуты следующие результаты:
* **Реализовано автоматическое наполнение таблиц** (`Events`, `Clients`, `Managers`, `Event_types`) случайными согласованными данными объемом более 100 и 1000 кортежей с помощью встроенных генераторов серий `generate_series()` и математических функций распределения `random()`.
* **Спроектированы и внедрены индексы различных конфигураций**: классический одноколоночный (для фильтрации по числу гостей), многоколоночный (для композитных запросов «менеджер + бюджет») и частичный индекс (для быстрого доступа к сегменту дорогостоящих мероприятий с бюджетом > 400 000).
* **Проведен сравнительный анализ планов выполнения запросов** с помощью инструмента `EXPLAIN ANALYZE`. На практике зафиксированы и изучены различные операторы СУБД: последовательное сканирование (`Seq Scan`) при выборке неселективных данных, индексное сканирование (`Index Scan`) для точечных запросов, а также оптимизированная сортировка (`Index Scan Backward`) без использования оперативной памяти благодаря древовидной структуре B-Tree.

В результате проделанной оптимизации скорость выполнения аналитических выборок и операций фильтрации увеличилась, что подтверждает эффективность применения индексов для высоконагруженных клиент-серверных систем управления базами данных.
