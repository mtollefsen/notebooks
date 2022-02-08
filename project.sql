/*
customers - customer information
employees - employee information (contact info, who they report to)
offices - sales offices information (contact info, locations)
orders - customer's sales orders
orderdetails - each line of every sales order
payments - customers' payment records
productlines - list of product lines for scale model cars
products - list of scale model cars
*/

-- Shows name, # of columns, and # of rows for every table
   SELECT 'customers' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('customers')) AS column_count, 
	      COUNT(*) AS row_count
     FROM customers
UNION ALL
   SELECT 'employees' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('employees')) AS column_count, 
	      COUNT(*) AS row_count
     FROM employees
UNION ALL
   SELECT 'offices' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('offices')) AS column_count, 
	      COUNT(*) AS row_count
     FROM offices
UNION ALL
   SELECT 'orders' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('orders')) AS column_count, 
	      COUNT(*) AS row_count
     FROM orders
UNION ALL
   SELECT 'orderdetails' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('orderdetails')) AS column_count, 
	      COUNT(*) AS row_count
     FROM orderdetails
UNION ALL
   SELECT 'payments' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('payments')) AS column_count, 
	      COUNT(*) AS row_count
     FROM payments
UNION ALL
   SELECT 'productlines' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('productlines')) AS column_count, 
	      COUNT(*) AS row_count
     FROM productlines
UNION ALL
   SELECT 'products' AS table_name, 
          (SELECT COUNT(*) 
             FROM pragma_table_info('products')) AS column_count, 
	      COUNT(*) AS row_count
     FROM products;
	 
	 
-- Shows the product codes that should be restocked
-- specifically, those that sell well and are low in stock	  
	  WITH 
	       quantity_sold AS (
	SELECT productCode, SUM(quantityOrdered) AS total_ordered
	  FROM orderdetails
  GROUP BY productCode
	  ),
	       high_perf_products AS (
	SELECT productCode
	  FROM orderdetails
  GROUP BY productCode
  ORDER BY SUM(quantityOrdered * priceEach) DESC
     LIMIT 10
	  ),
	       low_stock_products AS (
	SELECT p.productCode
      FROM quantity_sold qs
	  JOIN products p
	    ON p.productCode = qs.productCode
  ORDER BY qs.total_ordered / p.quantityInStock
     LIMIT 10
	  )
	  
	SELECT *
	  FROM products
     WHERE productCode IN low_stock_products AND
	       productCode IN high_perf_products;
	
-- Shows the top and bottom five customers in terms of profits
-- also shows the average customer lifetime value 
	  WITH
	       customer_profits AS (
	SELECT o.customerNumber, ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)), 2) 
	       AS total_profit_from
	  FROM orderdetails od
	  JOIN orders o ON o.orderNumber = od.orderNumber
	  JOIN products p ON p.productCode = od.productCode
  GROUP BY o.customerNumber
	)

		  SELECT c.customerName, p.productLine,
		         SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
	  FROM customers c
	  JOIN orders o ON c.customerNumber = o.customerNumber
	  JOIN orderdetails od ON o.orderNumber = od.orderNumber
	  JOIN products p ON p.productCode = od.productCode
	  JOIN productlines pl ON pl.productLine = p.productLine
	  WHERE c.customerNumber IN (SELECT customerNumber
								   FROM customer_profits
							   ORDER BY total_profit_from DESC
							      LIMIT 5)
	  GROUP BY c.customerName, p.productLine
	  ORDER BY c.customerName, profit DESC;
	
	
	
	SELECT c.contactLastName, c.contactFirstName, c.city,
	       c.country,
		   cp.total_profit_from
	  FROM customers c
	  JOIN customer_profits cp ON c.customerNumber = cp.customerNumber
  ORDER BY cp.total_profit_from DESC
	 LIMIT 5;

	SELECT c.contactLastName, c.contactFirstName, c.city,
	       c.country,
		   cp.total_profit_from
	  FROM customers c
	  JOIN customer_profits cp ON c.customerNumber = cp.customerNumber
  ORDER BY cp.total_profit_from
	 LIMIT 5;

	SELECT ROUND(AVG(total_profit_from), 2) AS average_customer_LTV
	  FROM customer_profits;
	  

