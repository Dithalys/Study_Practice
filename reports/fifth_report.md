# 🏛️ Практика №5: Работа с группами ролей и ролями

**Дисциплина:** [Клиент-серверные системы управления базами данных](../README.md)  
**Запросы:** [fifth_practice.sql](../src/database/fourth_practice.sql)  
**Предыдущая работа:** [Практика №4: Работа с транзакциями](./fourth_report.md)
**Следующая работа:** [Практика №6: Работа с индексами](./sixth_report.md)

> 💡 *Примечание: Все имена, персонажи и данные в настоящей работе являются вымышленными. Любое совпадение с реальными людьми случайно.*

---

## 🎯 Техническое задание

В [реализованную по выбору базу данных](./second_report.md) создать минимум 3 группы роли пользователей с различных функционалом:

Одна группа ролей должна иметь права\привилегии на создание\изменение и редактирование существующей базы данных
Вторая группа ролей должна иметь права\привилегии на редактирование определенных таблиц в базе данных, к остальным - на чтение
Третья группа ролей должна иметь права\привилегии только на чтение определенных таблиц, остальные для группы должны быть недоступны
В каждой группе ролей должна быть минимум одна роль
Каждая роль должна совершать в базу данных как минимум одну транзакцию ([можно использовать транзакции с практической работы №4](./fourth_report.md))

---

## 📥 DML: запросы

### 1. Создание групповых ролей (GROUP ROLES / ROLES)

```sql
CREATE ROLE db_admin_group;
CREATE ROLE db_manager_group;
CREATE ROLE db_analyst_group;
```

### 2. Назначение прав и привелегий (GRANT)

```sql
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
```

### 3. Создание персональных ролей и включение в группы

```sql
CREATE ROLE admin_user WITH LOGIN PASSWORD 'AdminSecurePass2026';
GRANT db_admin_group TO admin_user;
CREATE ROLE manager_user WITH LOGIN PASSWORD 'ManagerPass2026';
GRANT db_manager_group TO manager_user;
CREATE ROLE analyst_user WITH LOGIN PASSWORD 'AnalystPass2026';
GRANT db_analyst_group TO analyst_user;
```

---

## 📝 Заключение

В ходе выполнения практической работы были успешно изучены и применены механизмы разграничения прав доступа и управления пользователями в реляционных базах данных на примере СУБД PostgreSQL. 

Были достигнуты следующие результаты:
* **Созданы три уникальные группы ролей** (`db_admin_group`, `db_manager_group`, `db_analyst_group`) с иерархической структурой привилегий, реализующие различные уровни бизнес-логики: от полного администрирования структуры БД до жестко ограниченного доступа «только на чтение» к определенным таблицам.
* **Реализован ролевой подход к безопасности (RBAC)**, при котором конкретные пользователи (`admin_user`, `manager_user`, `analyst_user`) наследуют права через групповые роли, что упрощает масштабирование и аудит прав доступа в клиент-серверной системе.
* **На практике проверено выполнение транзакций** в условиях различных контекстов безопасности с помощью механизма переключения сессий (`SET ROLE`). Доказано, что СУБД корректно блокирует несанкционированные операции (например, ограничение доступа аналитика к скрытым таблицам) и успешно выполняет разрешенные действия в рамках транзакций.

В результате проделанной работы была обеспечена надежная информационная безопасность данных, соответствующая принципу наименьших привилегий, что минимизирует риски случайного повреждения или утечки конфиденциальной информации.
