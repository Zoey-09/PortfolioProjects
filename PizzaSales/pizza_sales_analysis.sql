Tableau Dashboard: https://public.tableau.com/app/profile/tinajcyeh/viz/PizzaSales_16998013231940/Dashboard2
/*
Pizza Sales Data Analysis

Skills used: Join, subquery, Aggregate Functions, Formatting Functions.

*/

# Creating a master file for later data visualiztion
# Total orders
# Total Sales
# Total Items
# Average ordered value

SELECT 
	FORMAT(COUNT(DISTINCT s1.order_id), 0) as Total_Orders,
    CONCAT('$', FORMAT(SUM(s1.amount), 0)) as Total_Sales,
    FORMAT(SUM(s1.quantity), 0) as Total_Items,
    CONCAT('$', FORMAT((SUM(s1.amount) / COUNT(DISTINCT s1.order_id)), 2)) as Average_Order_Value

FROM (SELECT 
	od.order_id as order_id,
    o.date as order_date,
    o.time as order_time,
    od.pizza_id as pizza_id,
    pt.category as category,
    pt.pizza_name as pizza_name,
    p.size as size,
    od.quantity as quantity,
    p.price as price,
    od.quantity * p.price as amount
    
	FROM order_details od
		LEFT JOIN orders o USING (order_id)
		LEFT JOIN pizzas p USING (pizza_id)
		LEFT JOIN pizza_types pt USING (pizza_type_id)) s1;
   
# Sales and percentage by category
SELECT
	pt.category as category,
    CONCAT('$', FORMAT(SUM(od.quantity * p.price), 2)) as amount,
    CONCAT(FORMAT(SUM(od.quantity * p.price) * 100.0 / sum(SUM(od.quantity * p.price)) OVER (), 2),'%') as percentage
   

FROM order_details od
		LEFT JOIN pizzas p USING (pizza_id)
		LEFT JOIN pizza_types pt USING (pizza_type_id)
GROUP BY pt.category;

# Sales volumn by Month
SELECT
	MONTH(o.date) as months,
    CONCAT('$', FORMAT(SUM(od.quantity * p.price), 0)) as total_amount


FROM order_details od
		LEFT JOIN orders o USING (order_id)
		LEFT JOIN pizzas p USING (pizza_id)
GROUP BY months;
		
# The numbers of orders by Weekdays
SELECT
    DAYOFWEEK(o.date) as weekday_index,
    DAYNAME(o.date) as weekdays,
    FORMAT(COUNT(DISTINCT o.order_id), 0) as total_order


FROM order_details od
		LEFT JOIN orders o USING (order_id)
		LEFT JOIN pizzas p USING (pizza_id)
GROUP BY weekday_index, weekdays
ORDER BY weekday_index;

# Avg. order value by hours
SELECT
    HOUR(o.time) as hours,
    CONCAT('$', FORMAT((SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id)), 2)) as Average_Order_Value


FROM order_details od
		LEFT JOIN orders o USING (order_id)
		LEFT JOIN pizzas p USING (pizza_id)
GROUP BY hours
ORDER BY hours;

# Top 5 items
SELECT
	p.pizza_id as pizza_id,
    CONCAT(pizza_name,' , ',size) as pizza_names,
    SUM(od.quantity) as quantity,
    CONCAT('$', FORMAT(p.price, 2)) as price,
    CONCAT('$', FORMAT(SUM(p.price * od.quantity), 2)) as total_amount
    
FROM order_details od
		LEFT JOIN orders o USING (order_id)
		LEFT JOIN pizzas p USING (pizza_id)
		LEFT JOIN pizza_types pt USING (pizza_type_id)
GROUP BY pizza_id, pizza_names, p.price
ORDER BY quantity DESC
LIMIT 5;

# Bottom 5 items
SELECT
	p.pizza_id as pizza_id,
    CONCAT(pizza_name,' , ',size) as pizza_names,
    SUM(od.quantity) as quantity,
    CONCAT('$', FORMAT(p.price, 2)) as price,
    CONCAT('$', FORMAT(SUM(p.price * od.quantity), 2)) as total_amount
    
FROM order_details od
		LEFT JOIN orders o USING (order_id)
		LEFT JOIN pizzas p USING (pizza_id)
		LEFT JOIN pizza_types pt USING (pizza_type_id)
GROUP BY pizza_id, pizza_names, p.price
ORDER BY quantity ASC
LIMIT 5;
