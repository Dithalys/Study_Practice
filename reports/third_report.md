# 🏛️ Практика №3: Администрирование

**Дисциплина:** [Клиент-серверные системы управления базами данных](../README.md)  
**Запросы:** [third_practice.sql](../src/database/third_practice.sql)  
**Предыдущая работа:** [Практика №2: Доработка базы данных и оптимизация](./second_report.md)
**Следующая работа:** [Практика №4: Работа с транзакциями](./fourth_report.md)

> 💡 *Примечание: Все имена, персонажи и данные в настоящей работе являются вымышленными. Любое совпадение с реальными людьми случайно.*

---

## 🎯 Техническое задание

В [реализованную по выбору базу данных](./second_report.md) добавить:
1. 2 уникальные [схемы](https://postgrespro.ru/docs/postgrespro/13/ddl-schemas)
2. 2 уникальные [функции](https://postgrespro.ru/docs/postgrespro/13/xfunc-sql)
3. 2 уникальные [процедуры](https://postgrespro.ru/docs/postgrespro/13/sql-createprocedure)
4. 2 уникальных [триггера](https://postgrespro.ru/docs/postgrespro/13/triggers)

---

## 📥 DML: Отрисовка данных

### 1. Две схемы (Schemas)

```sql
-- Схема для аналитических отчетов и представлений
CREATE SCHEMA IF NOT EXISTS analytics;
-- Схема для кадровых вопросов и внутренней логики сотрудников
CREATE SCHEMA IF NOT EXISTS hr;
```

### 2. Две функции (Functions)

```sql
-- Расчет общей стоимости меню для мероприятия
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

-- Проверка остатка ингредиента на складе
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
```

### 3. Две процедуры (Procedures)

```sql
-- Регистрация платежа за мероприятие
CREATE OR REPLACE PROCEDURE hr.register_event_payment(
    p_event_id INT,
    p_client_id INT,
    p_amount NUMERIC(10,2),
    p_payment_type_id INT
)
AS $$
BEGIN
    -- Вставляем запись о платеже
    INSERT INTO Event_payments(amount, event_id, client_id, payment_type_id)
    VALUES (p_amount, p_event_id, p_client_id, p_payment_type_id);

    -- Обновляем текущий оплаченный бюджет мероприятия
    UPDATE Events
    SET budget = budget + p_amount
    WHERE id = p_event_id;
    
    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Массовое списание ингредиентов при завершении мероприятия
CREATE OR REPLACE PROCEDURE close_event_and_spend_ingredients(p_event_id INT)
AS $$
BEGIN
    -- Обновляем количество ингредиентов на складе на основе состава меню мероприятия
    UPDATE Ingredients i
    SET quantity = i.quantity - (em.quantity * pc.quantity)
    FROM Event_menu em
    JOIN Product_compound pc ON em.product_id = pc.product_id
    WHERE em.event_id = p_event_id AND pc.ingredients_id = i.id;

    -- Переводим статус мероприятия в "Завершен" (id = 4 согласно вашему INSERT)
    UPDATE Events
    SET status_id = 4
    WHERE id = p_event_id;

    COMMIT;
END;
$$ LANGUAGE plpgsql;
```

### 4. Два триггера (Triggers)

```sql
-- Валидация даты начала и окончания мероприятия
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

-- Логирование изменений статуса мероприятия
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
```

---

## 📝 Заключение

## 📝 Заключение

В ходе выполнения лабораторной работы база данных была успешно доработана элементами процедурного программирования и логического структурирования СУБД PostgreSQL. Были решены следующие задачи автоматизации и администрирования:

* **Изоляция и структурирование данных:** Созданы две независимые схемы (`analytics` и `hr`), позволяющие разграничить права доступа пользователей, отделить служебные логи от основных таблиц и сгруппировать логику по бизнес-направлениям.
* **Инкапсуляция вычислений:** Реализованные функции автоматизируют рутинные SELECT-запросы для подсчета финансовой стоимости банкетного меню и выполнения складской проверки доступности сырья без усложнения клиентского кода.
* **Управление транзакциями:** Написанные процедуры обеспечивают атомарность комплексных операций (таких как одновременное зачисление платежа с обновлением баланса ивента, либо массовое списание складских запасов при закрытии заказа).
* **Контроль целостности на уровне СУБД:** Внедренные триггеры гарантируют валидацию хронологии дат "на лету" (защита от логических ошибок ввода) и организуют независимый аудит изменений критически важных состояний системы (история статусов мероприятий).

В результате разработанные программные объекты перенесли часть ключевой бизнес-логики приложения непосредственно на сторону сервера базы данных, что повысило производительность системы, снизило сетевой трафик и обеспечило строгую консистентность данных.
