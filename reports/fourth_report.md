# 🏛️ Практика №4: Работа с транзакциями

**Дисциплина:** [Клиент-серверные системы управления базами данных](../README.md)  
**Запросы:** [third_practice.sql](../src/database/fourth_practice.sql)  
**Предыдущая работа:** [Практика №3: Администрирование](./third_report.md)
**Следующая работа:** [Практика №5: Работа с группами ролей и ролями](./fifth_report.md)

> 💡 *Примечание: Все имена, персонажи и данные в настоящей работе являются вымышленными. Любое совпадение с реальными людьми случайно.*

---

## 🎯 Техническое задание

В [реализованную по выбору базу данных](./second_report.md) добавить 3 уникальные транзакции, одна из которых должна выводить ошибку любого уровня исключения(например, "грязное чтение" или фантомное чтение)

---

## 📥 DML: Транзакции

### 1. Безопасное оформление заказа с проверкой бюджета (READ COMMITTED)

```sql
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
```

### 2. Формирование неизменяемого аналитического отчета (REPEATABLE READ)

```sql
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
```

### 3. Вызов исключения сериализации / Фантомного контроля (SERIALIZABLE)

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(budget) FROM Events; 
INSERT INTO Events(title, description, people_count, date_start, date_end, map_point, budget, manager_id, client_id, type_id, status_id)
VALUES ('Конкурентный Банкет', 'Тест ошибки', 50, '2026-11-01 12:00:00', '2026-11-01 18:00:00', 'Координаты', 60000.00, 3, 8, 1, 1);
COMMIT;
```
---

## 📝 Заключение

В ходе выполнения практической работы были успешно изучены и применены механизмы управления транзакциями в реляционных базах данных на примере СУБД PostgreSQL. 

Были достигнуты следующие результаты:
* **Реализованы три уникальных сценария транзакций** с различными уровнями изоляции (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`), каждый из которых решает конкретную бизнес-задачу (проверка бюджета, формирование аналитики и предотвращение аномалий данных).
* **Освоен синтаксис анонимных блоков PL/pgSQL** для реализации сложной логики с перехватом и генерацией пользовательских исключений (`RAISE EXCEPTION`), что позволило обеспечить бизнес-логику безопасного оформления заказов.
* **На практике изучены механизмы изоляции транзакций** и способы предотвращения классических феноменов конкурентного доступа (таких как «грязное чтение», «неповторяющееся чтение» и «фантомное чтение»). Сценарий с уровнем `SERIALIZABLE` наглядно демонстрирует подход к контролю целостности данных при параллельном вычислении агрегатных функций (параллельный расчет общего бюджета) и одновременной вставке новых записей.

В результате проделанной работы созданы надежные транзакционные механизмы, гарантирующие соблюдение принципов **ACID** (Атомарность, Согласованность, Изолированность, Долговечность) в разработанной клиент-серверной системе управления базами данных.
