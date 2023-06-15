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
