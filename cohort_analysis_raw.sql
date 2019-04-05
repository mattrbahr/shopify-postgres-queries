/* 
- Change table name in row 10 
- Update date in line 14
- To build a cohort analysis chart import into Google Sheets and pivot on first order date (rows)
*/

WITH all_orders AS (
	SELECT 
		customer__id, created_at::date AS order_date, id, subtotal_price
	FROM 
		shopify.orders
	WHERE 
		source_name = 'web'
	AND 
		created_at > '2018-10-10'
	GROUP BY 
		customer__id, order_date, id, subtotal_price
), first_order AS (
	SELECT customer__id, first_date, rank, id, subtotal_price
		FROM (
			SELECT
				customer__id, created_at::date AS first_date, id, subtotal_price,
				RANK () OVER (
				PARTITION BY orders.customer__id
				ORDER BY created_at ASC
				)
				FROM 
					shopify.orders
				WHERE 
					source_name = 'web'
				GROUP BY customer__id, id, subtotal_price, created_at
			) rank_filter WHERE RANK = 1
), final AS (
SELECT 
	first_order.customer__id, to_char(first_date, 'YYYY-MM') AS first_order_date, to_char(order_date, 'YYYY-MM') AS order_date, ((DATE_PART('year', order_date::date) - DATE_PART('year', first_date::date)) * 12 +
              (DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date))) AS months_from_first
FROM
	all_orders
LEFT JOIN first_order ON all_orders.customer__id = first_order.customer__id
WHERE first_order.first_date > '2018-10-10'
) 

SELECT 
   first_order_date,
   order_date,
   months_from_first,
   count(months_from_first) AS no_of_customers
FROM 
  final
GROUP BY 
  first_order_date,
  months_from_first, 
  order_date
