-- this is a basic count of orders with .edu email addresses attached to them 
-- change table name on line 8

WITH uni_customers AS (
	SELECT DISTINCT 
		customer__email
	FROM
		shopify.orders 
	WHERE 
		customer__email iLIKE '%edu'
)

SELECT substring(customer__email from '@(.*)\.edu') AS uni, count(*)
FROM uni_customers
GROUP BY uni
ORDER BY count DESC
