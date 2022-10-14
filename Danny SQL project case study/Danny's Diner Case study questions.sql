--## Case Study Questions --##

--What is the total amount each customer spent at the restaurant?

select * from sales
select * from menu
select * from members

select customer_id,sum(price) as Total_Amt from sales
left join menu
on sales.product_id = menu.product_id
group by customer_id;

--How many days has each customer visited the restaurant?

select customer_id,count(distinct(order_date)) as No_of_days_visited from sales
group by customer_id;

--What was the first item from the menu purchased by each customer?

With sales_CTE AS
(
Select customer_id, order_date, product_name,
DENSE_RANK() OVER (PARTITION BY s.customer_id
order by s.order_date) AS Rank
from sales s
join menu m
on s.product_id = m.product_id
)
select customer_id, product_name, order_date from sales_CTE
WHERE Rank = 1
group by customer_id, product_name, order_date;

--What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1 ( count(sales.product_id)) as most_purchased, product_name from sales
 join menu
on sales.product_id = menu.product_id
group by product_name
order by most_purchased desc;

--Which item was the most popular for each customer?

WITH fav_item_cte AS
(
 SELECT s.customer_id, m.product_name, 
  COUNT(m.product_id) AS order_count,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY COUNT(s.customer_id) DESC) AS rank
FROM dbo.menu AS m
JOIN dbo.sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM fav_item_cte 
WHERE rank = 1;

--Which item was purchased first by the customer after they became a member?

With item_purchased_first_CTE AS
(
select sales.customer_id, join_date, order_date, product_name, DENSE_RANK() OVER (PARTITION BY sales.customer_id order by order_date) AS Rank
from sales
join members
on sales.customer_id = members.customer_id
join menu
on sales.product_id = menu.product_id
where order_date >= join_date
)
select customer_id, join_date, order_date, product_name
from item_purchased_first_CTE
where Rank = 1 

--Which item was purchased just before the customer became a member?

With item_purchased_first_CTE AS
(
select sales.customer_id, join_date, order_date, product_name, DENSE_RANK() OVER (PARTITION BY sales.customer_id order by order_date DESC) AS Rank
from sales
join members
on sales.customer_id = members.customer_id
join menu
on sales.product_id = menu.product_id
where order_date < join_date
)
select customer_id, join_date, order_date, product_name
from item_purchased_first_CTE
where Rank = 1 

--What is the total items and amount spent for each member before they became a member?

select sales.customer_id, count(sales.customer_id) as Total_items ,sum(price) as Amt_spent
from sales
join members
on sales.customer_id = members.customer_id
join menu
on sales.product_id = menu.product_id
where order_date < join_date
group by sales.customer_id;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_CTE AS
(
select sales.customer_id, 
CASE
	WHEN sales.product_id = 1 THEN price * 20
	ELSE price * 10
END AS points
from sales 
join menu
on sales.product_id = menu.product_id
)
select customer_id, SUM(points_CTE.points) as total_points from points_CTE
group by customer_id

