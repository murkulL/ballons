SELECT products.product_name, suppliers.company_name, products.unit_price, products.units_in_stock, SUM(products.unit_price * products.units_in_stock) AS countAllPrice
FROM products
INNER JOIN suppliers ON suppliers.supplier_id = products.supplier_id
WHERE products.discontinued <> 1
GROUP BY products.product_name, suppliers.company_name, products.unit_price, products.units_in_stock
HAVING SUM(products.unit_price * products.units_in_stock) > 3000
ORDER BY countAllPrice DESC;



SELECT categories.category_name, SUM(products.unit_price * products.units_in_stock) AS price
FROM categories
JOIN products ON products.category_id = categories.category_id
WHERE products.discontinued <> 1
GROUP BY categories.category_name
HAVING SUM(products.unit_price * products.units_in_stock) > 5000
ORDER BY price DESC;




CREATE TABLE employee (
	employee_id INT PRIMARY KEY,
	first_name VARCHAR(255) NOT NULL, 
	last_name VARCHAR(255) NOT NULL,
	manager_id INT,
	FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);

INSERT INTO employee(
	employee_id,
	first_name,
	last_name,
	manager_id
)

VALUES
(1,'Windy','Hays', NULL),
(2,'Ava','Christensen', 1),
(3,'Hassan','Conner', 1),
(4,'Anna','Reeves', 2),
(5,'Sau','Norman', 2),
(6,'Kelsie','Hays', 3),
(7,'Tory','Goff', 3),
(8,'Salley','Lester', 3);

select e.first_name || ' ' || e.last_name AS employee,
	   m.first_name || ' ' || e.last_name AS manager
FROM employee e
LEFT JOIN employee m ON m.employee_id = e.manager_id
ORDER BY manager



SELECT c.company_name, CONCAT(e.first_name, ' ', e.last_name) 
FROM orders AS o
JOIN customers AS c USING(customer_id)
JOIN employees AS e USING (employee_id)
JOIN shippers AS s ON o.ship_via = s.shipper_id
WHERE c.city = 'London' AND e.city = 'London' AND s.company_name = 'Speedy Express';

----------------------------------------------------

SELECT product_name, units_in_stock, contact_name, phone
FROM products
JOIN suppliers USING(supplier_id)
JOIN categories USING(category_id)
WHERE category_name IN('Seafood','Beverages') AND discontinued <> 1 AND units_in_stock < 20
ORDER BY units_in_stock 
 
--------------------------------------------------------

SELECT contact_name, order_id
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE order_id IS NULL
ORDER BY order_id DESC

-------------------------------------------------------


SELECT contact_name, order_id
FROM orders
FULL JOIN customers ON customers.customer_id = orders.customer_id
WHERE order_id IS NULL
ORDER BY order_id DESC




-------------------------------------------------------------
SELECT *
FROM employees
WHERE EXISTS (
  SELECT 1
  FROM orders
  WHERE orders.employee_id = employees.employee_id
);

-- Использование SELECT 1 вместо SELECT * или выбора конкретных
-- столбцов является хорошей практикой в таких случаях, поскольку
-- оно эффективнее с точки зрения производительности. Запрос
-- SELECT 1 возвращает только одно значение "1" для каждой 
-- строки, в то время как SELECT * вернул бы все столбцы таблицы
-- "orders", что может потребовать больше ресурсов для выполнения запроса.



--выбрать продукты которые не покупались с периода 95-02-1 по 95-02-15

SELECT product_name 
FROM products
WHERE NOT EXISTS(SELECT orders.order_id
				FROM orders
				INNER JOIN order_details USING(order_id) 
				WHERE order_details.product_id = products.product_id 
				AND order_date BETWEEN '1995-02-01' AND '1995-02-15'
 ) 




-------------------------------------------------------------

SELECT company_name, country
FROM suppliers
WHERE country IN (SELECT DISTINCT country
FROM customers )

--РАВНЫЕ ПО ЗНАЧЕНИЮ 

SELECT DISTINCT suppliers.company_name
FROM suppliers
JOIN customers USING(country)

--------------------------------------------------------
В SQL ключевое слово "ANY" используется в операторе сравнения для выполнения сравнения с любым значением из набора значений. Оно может быть использовано с операторами сравнения, такими как "=", ">", "<", ">=", "<=", "<>", "IN" и "LIKE".

Вот несколько примеров использования ключевого слова "ANY" в SQL:

Использование оператора сравнения "=" с ключевым словом "ANY":

SELECT * FROM employees WHERE age = ANY (25, 30, 35);
Этот запрос вернет все записи из таблицы "employees", где значение столбца "age" равно любому из значений 25, 30 или 35.

---


Использование оператора сравнения ">" с ключевым словом "ANY":

SELECT * FROM products WHERE price > ANY (SELECT price FROM products WHERE category = 'Electronics');

В этом примере будет выбраны все записи из таблицы 
"products", где цена продукта больше любой цены
 продукта в категории "Electronics"


----
Использование оператора "IN" с ключевым словом "ANY":

SELECT * FROM orders WHERE status IN (ANY ('Shipped', 'Delivered'));


Этот запрос вернет все записи из таблицы "orders", где статус заказа равен "Shipped" или "Delivered".




--ВЫБРАТЬ ТАКИЕ ПРОДУКТЫ КОЛИЧЕСТВО КОТОРЫХ БОЛЬШЕ СРЕДНЕГО ПО ЗАКАЗАМ

SELECT DISTINCT product_name, quantity
FROM products
JOIN order_details USING(product_id)
WHERE quantity > ( SELECT AVG(quantity)
				   FROM order_details)
ORDER BY quantity DESC




-- нужно найти все продукты количество которых больше среднего значения.
-- количества заказаных товаров из групп полученых групперованием по product_id


SELECT DISTINCT product_name, quantity
FROM products
LEFT JOIN order_details ON order_details.product_id = products.product_id
WHERE quantity > ALL (SELECT AVG(quantity) 
						FROM order_details 
						GROUP BY product_id)
ORDER BY quantity DESC



-- Вывести продукты количество которых в продаже меньше самого малого среднего количества продуктов в деталях заказов (группировка по product_id).
-- Результирующая таблица должна иметь колонки product_name и units_in_stock.


SELECT product_name, units_in_stock
FROM products
JOIN order_details USING(product_id)
WHERE units_in_stock < ALL (SELECT AVG(quantity)
							FROM order_details
						    GROUP BY product_id)
GROUP BY product_id 
ORDER BY units_in_stock DESC;


----------------------------------------------------------------------


--2. Напишите запрос, который выводит общую сумму фрахтов заказов для компаний-заказчиков для заказов,
--   стоимость фрахта которых больше или равна средней величине стоимости фрахта всех заказов,
--   а также дата отгрузки заказа должна находится во второй половине июля 1996 года.
--   Результирующая таблица должна иметь колонки customer_id и freight_sum, строки которой должны быть отсортированы по сумме фрахтов заказов.

-- Сумма фрахтов (англ. "freight charges") представляет собой общую стоимость или плата, которую необходимо заплатить за перевозку груза или товаров от одного места к другому.


SELECT customer_id, SUM(freight) AS freight_sum 
FROM orders 
INNER JOIN (SELECT customer_id, AVG(freight) AS freight_avg
			FROM orders
			GROUP BY customer_id) AS _

USING(customer_id)
WHERE freight > freight_avg AND shipped_date BETWEEN '1996-07-16' AND '1996-07-31'
GROUP BY customer_id
ORDER BY freight_sum



--3. Напишите запрос, который выводит 3 заказа с наибольшей стоимостью, которые были созданы после 1 сентября 1997 года включительно
--и были доставлены в страны Южной Америки. Общая стоимость рассчитывается как сумма стоимости деталей заказа с учетом дисконта.
--Результирующая таблица должна иметь колонки customer_id, ship_country и order_price, строки которой должны быть отсортированы по стоимости заказа в обратном порядке.

SELECT customer_id , ship_country, order_price
FROM orders
JOIN (SELECT order_id, SUM(unit_price * quantity - unit_price * quantity * discount) AS order_price
      FROM order_details
      GROUP BY order_id) AS od
	  
USING(order_id)
WHERE ship_country IN ('Argentina','Bolivia', 'Brazil', 'Chile', 'Colombia' )
AND order_date >= '1997-09-01'
ORDER BY order_price DESC
LIMIT 3;


-----------------------------------------------------------------------------

-- 4. Вывести все товары (уникальные названия продуктов), которых заказано ровно 10 единиц (конечно же, это можно решить и без подзапроса).

SELECT DISTINCT product_name, quantity
FROM products
JOIN order_details USING(product_id)
WHERE quantity = 10



------------------------------------------------------------------------------------------------






--ПЕРВАЯ ЧАСТЬ DDL-(Date Definition Language)

CREATE TABLE student (
	
	student_id serial,
	first_name varchar,
	last_name varchar,
	birthday date,
	phone varchar
);

CREATE TABLE cathedra(
	
	cathedra_id serial,
	cathedra_name varchar,
	dean varchar
	
);

---------------------------

ALTER TABLE student
ADD COLUMN middle_name varchar; -- фамилия

ALTER TABLE student 
ADD COLUMN rating float; -- рейтинг ученика 

ALTER TABLE student 
ADD COLUMN enrolled date; -- дата когда студент был зачислен 



ALTER TABLE student 
DROP COLUMN middle_name --если хотим удалить столбец



ALTER TABLE cathedra
RENAME TO chair --если хотим переименовать таблицу chair == кафедра 



ALTER TABLE chair
RENAME cathedra_id TO chair_id  --если хотим переименовать колонку 



ALTER TABLE student 
ALTER COLUMN first_name SET DATA TYPE VARCHAR(64);-- изметить тип данных в колонке 
ALTER TABLE student 
ALTER COLUMN last_name SET DATA TYPE VARCHAR(64);-- изметить тип данных в колонке 
ALTER TABLE student 
ALTER COLUMN phone SET DATA TYPE VARCHAR(30);-- изметить тип данных в колонке 


CREATE TABLE faculty(
	
	faculty_id serial,-- serial тип данных как integer только добавляет функционал автоинкремента
					  -- это тоже саое что и IDENTITY только с небольшим отличием 
	faculty_name varchar
);
INSERT INTO faculty (faculty_name)-- если тип данных serial тогда нужно точно 
								  -- указывать куда мы вставляем данные 
VALUES 
('faculty 1'),
('faculty 2'),
('faculty 3');

SELECT *
FROM faculty

TRUNCATE TABLE faculty -- стирает данные но не рестартит полностью,
					   -- faculty_id при внисении новых данных будет начитаться не с (1,2,3) а с (4,5,6)
					   
TRUNCATE TABLE faculty RESTART IDENTITY -- доп функционал ПЕРЕЗАПУСТИТЬ ИДЕНТИФИКАЦИЮ, faculty_id будет начитаться с (1,2,3)
-- потому что в PostgreSQL по умолчанию используется команда CONTINUE IDENTITY !!!

DROP TABLE faculty
















--------1
CREATE TABLE teacher(
	teacher_id serial,
	first_name varchar,
	last_name varchar,
	birthday date,
	phone varchar,
	title varchar
);



--------2

ALTER TABLE teacher
ADD COLUMN middle_name varchar

--------3

ALTER TABLE teacher
DROP COLUMN middle_name


--------4

ALTER TABLE teacher
RENAME birthday TO birth_date

--------5

ALTER TABLE teacher
ALTER COLUMN phone SET DATA TYPE varchar(32)


--------6
--------7
--------8
CREATE TABLE exam(
	
	exam_id serial,
	exam_name varchar(256),
	exam_date date
);
INSERT INTO exam (exam_name, exam_date)
VALUES 
('MATH','1999-09-30'),
('MATH','1999-09-30'),
('MATH','1999-09-30'),
('MATH','1999-09-30');

select * 
from exam

--------9

TRUNCATE TABLE exam RESTART IDENTITY


DROP TABLE chair
-------------------------------------------------------
CREATE TABLE chair
(
	chair_id serial PRIMARY KEY,-- PRIMARY KEY гарантирует что я не смогу вставить дублекат в эту колону
								-- то есть накладывает ограничение УНИКАЛЬНОСТИ 
								-- так же PRIMARY KEY запрещает всталять NULL
	
	chair_name varchar,
	dean varchar
);

----------------------------------------------------------
CREATE TABLE chair
(
	chair_id serial UNIQUE NOT NULL --UNIQUE(уникальный) по свойствам тоже самое за одним исключением 
									-- у UNIQUE нет поумолчанию NOT NULL ,нужно задавать отдельно 
	
	chair_name varchar,
	dean varchar
);

-----------------------------------------------------------------------
INSERT INTO chair 
VALUES 

(2, 'name', 'dean')


SELECT *
FROM chair



-- разница между UNIQUE NOT NULL и PRIMARY KEY в том что PRIMARY KEY на всю табличку может быть только один
-- а UNIQUE и UNIQUE NOT NULL может быть более чем на одну колонку наложить ограничение по уникальности
-- в любом случае PRIMARY KEY пользуються что бы иксплицидно пометить где у нас первичный ключь
-- который используется для связки со внешним ключем и уникально идентифицирует сроку в целой таблице
--
-- в общем и целом существенной разницы между UNIQUE NOT NULL и PRIMARY KEY нет 
--
--






-- есть кусочек кода с помощью которого мы можем вывести имена которые даны ограничением 

SELECT constraint_name
FROM information_schema.key_column_usage
WHERE table_name = 'chair'
	AND table_schema = 'public'
	AND column_name = 'chair_id'
	
	
--1 SELECT constraint_name - выбираются значения столбца constraint_name.
--2 FROM information_schema.key_column_usage - таблица, из которой выбираются данные, называется information_schema.key_column_usage. Эта таблица содержит информацию о столбцах, используемых в ключевых ограничениях (primary key, foreign key) в базе данных.
--3 WHERE table_name = 'chair' - условие, что мы ищем информацию для таблицы с именем 'chair'.
--4 AND table_schema = 'public' - условие, что таблица находится в схеме с именем 'public'.
--5 AND column_name = 'chair_id' - условие, что мы ищем информацию для столбца с именем 'chair_id'.

ALTER TABLE chair 
ADD PRIMARY KEY (chair_id)-- добавляем ограничения

ALTER TABLE chair 
DROP CONSTRAINT chair_id-- удаляем ограничения


---------------------------------------------------




--ВНЕШНИЕ КЛЮЧИ (которые так же включают в себя ограничения)


CREATE TABLE publisher

(
	publisher_id INT, 
	publisher_name varchar(128) NOT NULL,
	address text,
	CONSTRAINT PK_publisher_publisher_id PRIMARY KEY(publisher_id)
 -- CONSTRAINT FK_book_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id)
);

ALTER TABLE book 
DROP CONSTRAINT FK_book_publisher -- удалить ограничения 

CREATE TABLE book
(
	book_id int,
	title text NOT NULL ,
	isbs VARCHAR(32) NOT NULL,
	publisher_id int,
	
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
	
);


INSERT INTO publisher
VALUES 
(1, 'Evetyman''s Library', 'NY'),
(2, 'Evetyman''s Library', 'NY'),
(3, 'Evetyman''s Library', 'NY'),
(4, 'Evetyman''s Library', 'NY'),
(5, 'Evetyman''s Library', 'NY'),
(6, 'Evetyman''s Library', 'NY');



INSERT INTO book
VALUES 
(1, 'Evetyman''s Library', '234234234234', 10) -- колонка ссылаеться на не верную колону 


TRUNCATE TABLE book 


select *
from book


ALTER TABLE book 
ADD CONSTRAINT FK_book_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id)
-- что бы вносить правельные ссылки на publisher нужно писать следующий код 
-- что бы не нарушать ограничения внешнего ключа 
