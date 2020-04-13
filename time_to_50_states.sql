/* 
- Change table name in row 12 
- Update date in line 14
- We could write this to look for your first order, but assuming it would have pre-launch noise. 
*/

WITH state_rank AS (
	SELECT date_trunc('DAY',(created_at AT TIME ZONE 'EST')) AS day, shipping_address__province,
		RANK() OVER (
		PARTITION BY orders.shipping_address__province
		ORDER BY created_at ASC
)
	FROM shopify.orders
	WHERE customer__email IS NOT NULL
	AND created_at > '{{launch date}}'
	AND financial_status = 'paid'
	AND source_name = 'web'
	AND total_price > 0

)

SELECT day, shipping_address__province
FROM state_rank
WHERE rank = 1
AND shipping_address__province IS NOT NULL
ORDER BY day DESC
