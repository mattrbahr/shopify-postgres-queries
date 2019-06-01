/*
- Change table name in row 10
- lines 7-8 denote your groupings
*/

with order_amounts as (
select
    case when subtotal_price > 599 then 600
    else round(subtotal_price / 10 - .5) * 10
    end as average_aov
from
    shopify.orders
where
    subtotal_price > 0
)

select average_aov, count(average_aov)
from order_amounts
group by average_aov
order by average_aov asc
