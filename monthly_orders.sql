-- Change table name on line 12 and 20
-- You can filter additional orders by adding additional `where` statement on line 17

WITH 
	customer_order AS (
SELECT date_trunc('MONTH',(created_at AT TIME ZONE 'EST')) AS month, total_line_items_price::money, total_discounts::money, customer__email, customer__orders_count, created_at::date, order_number, _id, subtotal_price::money,
		RANK() OVER (
		PARTITION BY orders.customer__email
		ORDER BY created_at ASC
)
	FROM shopify.orders
	WHERE customer__email IS NOT NULL
	AND financial_status = 'paid'
	AND source_name = 'web'
	AND total_price > 0
),
	order_qty AS (
SELECT orders__line_items._sdc_source_key_id, SUM(quantity) AS order_quantity
FROM shopify.orders__line_items
GROUP BY orders__line_items._sdc_source_key_id
), 
	table_all AS (
SELECT *
FROM customer_order
LEFT JOIN order_qty ON order_qty._sdc_source_key_id = customer_order._id
)

SELECT 
	MONTH::date AS "Month",
	COUNT(DISTINCT customer__email) AS "Customers",
	COUNT(DISTINCT customer__email) FILTER (WHERE rank = 1) AS "New Customers",
	COUNT(_id) AS "Total Orders",
	SUM(order_quantity) AS "Total Unit Quantity",
	SUM(subtotal_price) / COUNT(_id) AS "Average Order Value",
	SUM(total_line_items_price) AS "Gross Revenue",
	SUM(total_line_items_price) - SUM(total_discounts) AS "Net Revenue",
	SUM(total_discounts) AS "Total Discounts"
FROM table_all
GROUP BY month
ORDER BY month DESC
LIMIT 40

