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

INSERT INTO Roles(title) VALUES('Директор') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Администратор') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Менеджер') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Супервайзер') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Шеф-повар') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Повар-универсал') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Официант') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Доставщик') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Хелпер') ON CONFLICT (title) DO NOTHING;
INSERT INTO Roles(title) VALUES('Заказчик') ON CONFLICT (title) DO NOTHING;

INSERT INTO Event_types(title) VALUES('Банкет') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_types(title) VALUES('Фуршет') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_types(title) VALUES('Кофе-брейк') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_types(title) VALUES('Коктейльная-вечеринка') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_types(title) VALUES('Пикник') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_types(title) VALUES('Гала-ужин') ON CONFLICT (title) DO NOTHING;

INSERT INTO Payment_types(title) VALUES('Наличные') ON CONFLICT (title) DO NOTHING;
INSERT INTO Payment_types(title) VALUES('Банковская карта') ON CONFLICT (title) DO NOTHING;
INSERT INTO Payment_types(title) VALUES('Безналичный расчет') ON CONFLICT (title) DO NOTHING;
INSERT INTO Payment_types(title) VALUES('СБП') ON CONFLICT (title) DO NOTHING;

INSERT INTO Event_statuses(title) VALUES('В обработке') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_statuses(title) VALUES('Отменен') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_statuses(title) VALUES('В работе') ON CONFLICT (title) DO NOTHING;
INSERT INTO Event_statuses(title) VALUES('Завершен') ON CONFLICT (title) DO NOTHING;

INSERT INTO Product_categories(title) VALUES('Классический кофе') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Авторские рафы и латте') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Чай и согревающие напитки') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Лимонады и айс-кофе') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Канапе и брускетты') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Мини-бургеры и тарталетки') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Горячие закуски') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Десерты и выпечка') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Сладкие боксы и макаронс') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Веганское и фитнес меню') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Сиропы и топпинги') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Растительное молоко') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Холодные закуски и плато') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Салаты в верринах') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Стрит-фуд и мини-доги') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('BBQ и блюда на гриле') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Фруктовые тарелки и шпажки') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Безалкогольные коктейли') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Матча и альтернативный чай') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Свежевыжатые соки и смузи') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Детское фуршетное меню') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Праздничные торты') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Аренда посуды и текстиля') ON CONFLICT (title) DO NOTHING;
INSERT INTO Product_categories(title) VALUES('Услуги персонала и бариста') ON CONFLICT (title) DO NOTHING;

INSERT INTO Ingredient_Units(title) VALUES('Кг') ON CONFLICT (title) DO NOTHING;
INSERT INTO Ingredient_Units(title) VALUES('Литр') ON CONFLICT (title) DO NOTHING;
INSERT INTO Ingredient_Units(title) VALUES('Шт') ON CONFLICT (title) DO NOTHING;