/* 
- Change table name in row 12 
- Update date in line 14
*/

WITH state_rank AS (
	SELECT date_trunc('DAY',(created_at AT TIME ZONE 'EST')) AS DAY, shipping_address__province,
		RANK() OVER (
		PARTITION BY orders.shipping_address__province
		ORDER BY created_at ASC
)
	FROM shopify.orders
	WHERE customer__email IS NOT NULL
	AND created_at > '2018-10-09'
	AND financial_status = 'paid'
	AND source_name = 'web'
	AND total_price > 0

)

SELECT day, shipping_address__province
FROM state_rank
WHERE rank = 1
AND shipping_address__province IS NOT NULL
ORDER BY day DESC
