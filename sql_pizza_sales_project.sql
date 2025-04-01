Create database pizzahut;
use pizzahut;
create table orders(
order_id int primary key not null,
orderdate date not null,
order_time time not null
);

# Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

# Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id;

# Identify the highest-priced pizza.
SELECT 
    pt.name, p.price AS highest_price_pizza
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY 2 DESC
LIMIT 1;

# Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

# List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

# Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

# Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY 1;

# Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS pizza_count
FROM
    pizza_types
GROUP BY 1;

# Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.orderdate, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY 1) AS order_quantity;

# or

with cte as (select o.orderdate, sum(od.quantity) as quantity
from orders as o
join order_details as od
on o.order_id = od.order_id
group by 1)
select round(avg(quantity),0) as avg_pizza_ordered_per_day from cte;

# Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(p.price * od.quantity) AS total_revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

# Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity) / (SELECT 
                    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
                FROM
                    pizzas AS p
                        JOIN
                    order_details AS od ON p.pizza_id = od.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

# Analyze the cumulative revenue generated over time.
select orderdate, 
sum(revenue) over(order by orderdate) as cum_revenue
from
(select o.orderdate, round(sum(p.price*od.quantity),2) as revenue
from pizzas as p
join order_details as od
on p.pizza_id = od.pizza_id
join orders as o
on o.order_id = od.order_id
group by 1) as sales;

# Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue 
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rnk
from
(select pt.category, pt.name, sum(p.price*od.quantity) as revenue
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id
group by 1,2) as a) as b
where rnk <=3;