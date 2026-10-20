CREATE TABLE IF NOT EXISTS Roles(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Event_types(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Payment_types(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Event_statuses(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Product_categories(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Ingredient_Units(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Users(
    id SERIAL PRIMARY KEY,
    login VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    mid_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    birthday DATE,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role_id INT REFERENCES Roles(id)
);

CREATE TABLE IF NOT EXISTS Products(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) DEFAULT 0,
    category_id INT REFERENCES Product_categories(id)
);

CREATE TABLE IF NOT EXISTS Ingredients(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) DEFAULT 0,
    quantity INT DEFAULT 0,
    unit_id INT REFERENCES Ingredient_Units(id)
);

CREATE TABLE IF NOT EXISTS Product_compound(
    id SERIAL PRIMARY KEY,
    quantity INT DEFAULT 0,
    product_id INT REFERENCES Products(id),
    ingredients_id INT REFERENCES Ingredients(id)
);

CREATE TABLE IF NOT EXISTS Events(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    people_count INT NOT NULL,
    date_start TIMESTAMP NOT NULL,
    date_end TIMESTAMP NOT NULL,
    map_point VARCHAR(255) NOT NULL,
    budget NUMERIC(10,2) DEFAULT 0,
    manager_id INT REFERENCES Users(id),
    client_id INT REFERENCES Users(id),
    type_id INT REFERENCES Event_types(id),
    status_id INT REFERENCES Event_statuses(id)
);

CREATE TABLE IF NOT EXISTS Event_payments(
    id SERIAL PRIMARY KEY,
    amount NUMERIC(10,2) DEFAULT 0,
    event_id INT REFERENCES Events(id),
    client_id INT REFERENCES Users(id),
    payment_type_id INT REFERENCES Payment_types(id)
);

CREATE TABLE IF NOT EXISTS Event_employees(
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES Events(id),
    employee_id INT REFERENCES Users(id),
    task VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Event_menu(
    id SERIAL PRIMARY KEY,
    quantity INT DEFAULT 0,
    event_id INT REFERENCES Events(id),
    product_id INT REFERENCES Products(id)
);

INSERT INTO Roles(title) VALUES 
('Директор'), ('Администратор'), ('Менеджер'), ('Супервайзер'), ('Шеф-повар'), 
('Повар-универсал'), ('Официант'), ('Доставщик'), ('Хелпер'), ('Заказчик')
ON CONFLICT (title) DO NOTHING;

INSERT INTO Event_types(title) VALUES 
('Банкет'), ('Фуршет'), ('Кофе-брейк'), ('Коктейльная-вечеринка'), ('Пикник'), ('Гала-ужин')
ON CONFLICT (title) DO NOTHING;

INSERT INTO Payment_types(title) VALUES 
('Наличные'), ('Банковская карта'), ('Безналичный расчет'), ('СБП')
ON CONFLICT (title) DO NOTHING;

INSERT INTO Event_statuses(title) VALUES 
('В обработке'), ('Отменен'), ('В работе'), ('Завершен')
ON CONFLICT (title) DO NOTHING;

INSERT INTO Product_categories(title) VALUES 
('Классический кофе'), ('Авторские рафы и латте'), ('Чай и согревающие напитки'), 
('Лимонады и айс-кофе'), ('Канапе и брускетты'), ('Мини-бургеры и тарталетки'), 
('Горячие закуски'), ('Десерты и выпечка'), ('Сладкие боксы и макаронс'), 
('Веганское и фитнес меню'), ('Сиропы и топпинги'), ('Растительное молоко'), 
('Холодные закуски и плато'), ('Салаты в верринах'), ('Стрит-фуд и мини-доги'), 
('BBQ и блюда на гриле'), ('Фруктовые тарелки и шпажки'), ('Безалкогольные коктейли'), 
('Матча и альтернативный чай'), ('Свежевыжатые соки и смузи'), ('Детское фуршетное меню'), 
('Праздничные торты'), ('Аренда посуды и текстиля'), ('Услуги персонала и бариста')
ON CONFLICT (title) DO NOTHING;

INSERT INTO Ingredient_Units(title) VALUES 
('Кг'), ('Литр'), ('Шт')
ON CONFLICT (title) DO NOTHING;