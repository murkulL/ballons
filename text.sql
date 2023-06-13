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