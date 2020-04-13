/* 
- Change table name in row 10 
- Update date in line 16
- Lines 16-18 help filter out order noise
*/

WITH 
 time_to_fulfill AS (
 		SELECT 
	 		to_char(orders.created_at, 'YY-MM') AS ym,
	 		orders.name, orders.created_at AS Order_created,
	 		orders__fulfillments.created_at AS fulfillment_created,
			ROUND(EXTRACT(EPOCH FROM (orders__fulfillments.created_at - orders.created_at))::numeric / 60,0) AS minutes_to_email
		FROM shopify.orders
		LEFT JOIN /*table*/shopify.orders__fulfillments ON orders.id = orders__fulfillments.order_id
		WHERE orders.created_at > '2018-09-10'
		AND source_name = 'web'
		AND fulfillment_status = 'fulfilled'
		ORDER BY orders.created_at ASC
	)	
SELECT 
	ym,
	ROUND(AVG(minutes_to_email),0) AS minutes_to,
	ROUND(AVG(minutes_to_email)/60,0) AS hours_to,
	ROUND(AVG(minutes_to_email)/60/24,2) AS day_to
FROM time_to_fulfill
GROUP BY ym
ORDER BY ym ASC
