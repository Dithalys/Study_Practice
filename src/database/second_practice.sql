CREATE TABLE IF NOT EXISTS Suppliers (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS Ingredient_Deliveries (
    id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES Suppliers(id),
    ingredient_id INT REFERENCES Ingredients(id),
    delivery_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity INT NOT NULL CHECK (quantity > 0),
    purchase_price NUMERIC(10,2) NOT NULL CHECK (purchase_price >= 0)
);

CREATE TABLE IF NOT EXISTS Equipment (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    total_quantity INT NOT NULL DEFAULT 0,
    rental_price_per_day NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Event_Equipment (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES Events(id),
    equipment_id INT REFERENCES Equipment(id),
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS Event_Reviews (
    id SERIAL PRIMARY KEY,
    event_id INT UNIQUE REFERENCES Events(id),
    client_id INT REFERENCES Users(id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT id, login, email FROM Users WHERE role_id = 1;

SELECT DISTINCT last_name FROM Users WHERE last_name LIKE 'И%' ORDER BY last_name ASC;

SELECT * FROM Products WHERE (price BETWEEN 500.00 AND 1500.00) AND (category_id = 2 OR category_id = 3);

SELECT id, title, budget FROM Events WHERE status_id IN (3, 4) AND manager_id NOT IN (10);

SELECT id, title FROM Ingredients WHERE description IS NULL LIMIT 5;

SELECT category_id, COUNT(*) AS total_products FROM Products GROUP BY category_id;

SELECT category_id, AVG(price) AS average_price FROM Products GROUP BY category_id HAVING AVG(price) > 1000;

SELECT client_id, SUM(amount) AS total_paid, MIN(amount) AS min_payment, MAX(amount) AS max_payment 
FROM Event_payments GROUP BY client_id;

SELECT e.title AS event_name, m.last_name AS manager, c.last_name AS client 
FROM Events e
INNER JOIN Users m ON e.manager_id = m.id
INNER JOIN Users c ON e.client_id = c.id;

SELECT p.title, COALESCE(c.title, 'Без категории') AS category_name 
FROM Products p
LEFT JOIN Product_categories c ON p.category_id = c.id;

SELECT DISTINCT pt.title FROM Event_payments ep 
RIGHT JOIN Payment_types pt ON ep.payment_type_id = pt.id 
WHERE ep.id IS NOT NULL;

SELECT e.id AS event_id, ep.id AS payment_id FROM Events e 
FULL OUTER JOIN Event_payments ep ON e.id = ep.event_id 
WHERE e.id IS NULL OR ep.id IS NULL;

SELECT id, login FROM Users u 
WHERE EXISTS (SELECT 1 FROM Event_payments ep WHERE ep.client_id = u.id);

SELECT title, price FROM Products 
WHERE price > (SELECT AVG(price) FROM Products);

SELECT first_name, last_name, phone_number, 'Клиент' AS user_type FROM Users WHERE role_id = (SELECT id FROM Roles WHERE title = 'Client')
UNION ALL
SELECT first_name, last_name, phone_number, 'Персонал' AS user_type FROM Users WHERE role_id != (SELECT id FROM Roles WHERE title = 'Client');

SELECT id, title, budget,
       CASE WHEN budget >= 500000 THEN 'Крупное' WHEN budget >= 100000 THEN 'Среднее' ELSE 'Бюджетное' END AS event_scale
FROM Events;

WITH RankedProducts AS (
    SELECT category_id, title, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank
    FROM Products
)
SELECT category_id, title, price FROM RankedProducts WHERE rank = 1;

SELECT manager_id, SUM(budget) as total_budget, DENSE_RANK() OVER (ORDER BY SUM(budget) DESC) as manager_rank
FROM Events GROUP BY manager_id;

SELECT title, quantity FROM Ingredients ORDER BY title OFFSET 10 ROWS FETCH FIRST 5 ROWS ONLY;

SELECT title, description FROM Events WHERE description ILIKE '%\%%' ESCAPE '\';
