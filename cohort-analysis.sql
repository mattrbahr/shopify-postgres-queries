	WITH orders_rank AS (
		SELECT
			orders.id, customer__id,
			to_char(created_at, 'YYYY-MM') AS order_date, 
			created_at, 
			CASE WHEN amount IS NULL THEN total_price - total_tax
			ELSE total_price - total_tax + amount END AS order_subtotal,
			rank() OVER (
					PARTITION BY 
						orders.customer__id
					ORDER BY 
						orders.created_at ASC
					) 
					AS order_rank
		FROM 
			weezie_shopify.orders
		LEFT JOIN
			weezie_shopify.orders__refunds__order_adjustments t2
			ON t2._sdc_source_key_id = orders.id
		WHERE
			customer__email NOT ILIKE '%weezie%' -- exclude internal orders
		AND
			to_char(created_at, 'YYYY-MM') > '2018-09' 
		AND
			subtotal_price > 0
		AND (amount > 0 or amount IS NULL)
	), monthly_rev AS (
		SELECT 
			order_date,
			sum(order_subtotal)
		FROM 
			orders_rank
		GROUP BY 
			order_date
	), new_customer_cohort AS (
		SELECT customer__id, order_date as cohort_date, orders_rank.created_at as cohort_date_exact
		FROM orders_rank
		WHERE order_rank = '1'
	), first_month_spend AS (
		SELECT 
			cohort_date, 
			sum(order_subtotal) as first_month
		FROM 
			orders_rank 
		LEFT JOIN 
			new_customer_cohort ON 
			orders_rank.customer__id = new_customer_cohort.customer__id
		WHERE 
			order_date = cohort_date
		GROUP BY 
			cohort_date
	
	), additional_spend AS (
		SELECT 
			cohort_date, 
			sum(order_subtotal) as subsequent_month
		FROM 
			orders_rank 
		LEFT JOIN 
			new_customer_cohort ON 
			orders_rank.customer__id = new_customer_cohort.customer__id
		WHERE 
			order_date != cohort_date
		AND
			cohort_date_exact > (created_at - INTERVAL '12 months') 
		GROUP BY 
			cohort_date
	)
	
	SELECT 
		t1.cohort_date as cohort, 
		first_month::money as cohort_month_rev, 
		subsequent_month::money as future_rev,
		first_month::money+subsequent_month::money as total_cohort_rev
	FROM 
		first_month_spend t1
	LEFT JOIN 
		additional_spend t2 ON t1.cohort_date = t2.cohort_date
	ORDER BY cohort ASC
