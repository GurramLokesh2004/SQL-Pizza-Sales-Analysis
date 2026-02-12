create database pizza;
use pizza;

select *from pizzas;
select * from pizza_types;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

-- Basic:
-- 1)Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- 2)Calculate the total revenue generated from pizza sales.
select round(sum(p.price*o.quantity),2) as total_revenue 
from pizzas as p
join order_details as o
on p.pizza_id=o.pizza_id;

-- 3)Identify the highest-priced pizza.
select pt.name,max(p.price) as highest_priced_pizza
from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id;

-- 4)Identify the most common pizza size ordered.
select p.size,count(p.size) as cnt from pizzas as p
join order_details as od
on p.pizza_id=od.pizza_id
group by p.size
order by cnt desc 
limit 1;

-- 5)List the top 5 most ordered pizza types along with their quantities.
select pt.name,pt.pizza_type_id,count(od.quantity) as cnt from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
join order_details as od 
on p.pizza_id=od.pizza_id
group by pt.pizza_type_id 
order by count(od.quantity) desc
limit 5;

-- Intermediate:
-- 1)Join the necessary tables to find the total quantity of each pizza category ordered.
select a.category,sum(od.quantity) as total_qty from(select pt.name,p.pizza_id,pt.category from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id) as a
join order_details as od
on a.pizza_id=od.pizza_id
group by a.category
order by total_qty desc;
;

-- 2)Determine the distribution of orders by hour of the day.
select * from orders;
select hour(o.order_time) as hour,sum(od.quantity) as total_qty from orders as o
join order_details as od
on o.order_id=od.order_id
group by hour
order by total_qty desc;

-- 3)Join relevant tables to find the category-wise distribution of pizzas.
select pt.name,pt.category,count(pt.name) as cnt from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.category
order by cnt desc;

-- 4)Group the orders by date and calculate the average number of pizzas ordered per day.
select day(o.order_date) as day,avg(od.quantity) as average_orders
from orders as o
join order_details as od
on o.order_id=od.order_id
group by day
order by avg(od.quantity);

-- 5)Determine the top 3 most ordered pizza types based on revenue.
select p.pizza_id,pt.name,round((p.price*od.quantity),2)revenue
from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on p.pizza_id=od.pizza_id
group by name
order by revenue desc
limit 3;
-- Advanced:
-- 1)Calculate the percentage contribution of each pizza type to total revenue.
select p.pizza_id,pt.name,round((p.price*od.quantity),2)revenue,round(((p.price*od.quantity)/sum(p.price*od.quantity))*100,2) as percentage
from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on p.pizza_id=od.pizza_id
group by name
order by revenue desc;
-- 2)Analyze the cumulative revenue generated over time.
select order_time as time,revenue,sum(revenue) over(partition by order_time order by revenue) as rgvt 
from(  select od.order_id,round((a.price*od.quantity),2) as revenue from(select p.pizza_id,p.price from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id) as a
join order_details as od 
on a.pizza_id=od.pizza_id) as b
join orders as o
on b.order_id=o.order_id;
-- 3)Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select pt.category, p.pizza_TYpe_id,pt.name,round((p.price*od.quantity),2)revenue
from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on p.pizza_id=od.pizza_id
group by name
order by revenue desc
limit 3;