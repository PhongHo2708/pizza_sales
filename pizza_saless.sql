CREATE TABLE pizza_sales (
    pizza_id INT,
    order_id INT,
    pizza_name_id VARCHAR(50),
    quantity INT,
    order_date DATE,
    order_time TIME,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    pizza_size CHAR(1),
    pizza_category VARCHAR(50),
    pizza_name VARCHAR(100)
);



ALTER TABLE pizza_sales
ALTER COLUMN pizza_size SET DATA TYPE VARCHAR(10);

SET datestyle = 'DMY';

COPY pizza_sales(pizza_id, order_id, pizza_name_id, quantity, order_date, order_time, unit_price, total_price, pizza_size, pizza_category, pizza_name)
FROM 'D:\pizza_sales.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM pizza_sales;

--KPI requirement
--tổng doanh thu
SELECT SUM(total_price) as Total_Revenue
FROM pizza_sales;
--trung bình đơn hàng hay số tiền trung bình chi cho mỗi đơn
SELECT SUM(total_price)/COUNT(DISTINCT order_id) AS Avg_order_value
FROM pizza_sales;
--tổng số pizza đã bán
SELECT SUM(quantity) AS Total_pizza_order
FROM pizza_sales;
--tổng số đơn đặt
SELECT COUNT(DISTINCT order_id) as Total_order
FROM pizza_sales;
--giá trị trung bình của 1 chiếc pizza
SELECT CAST(SUM(quantity) AS DECIMAL(10,2))/CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) as Avg_pizza_per
FROM pizza_sales;

--Chart requirement
--Daily trend for total orders
SELECT TO_CHAR(order_date,'day') as day_of_week, count (distinct order_id) as total_orders
FROM pizza_sales
GROUP BY day_of_week;
--Monthly trend for total orders
select Date_part('month',order_date) as order_month, count (distinct order_id) as total_orders
FROM pizza_sales
GROUP BY order_month;

--percentage theo sản phẩm
select pizza_category,SUM(total_price) as total_revenue, cast(SUM(total_price)*100 /(select sum(total_price)from pizza_sales) as decimal(10,2)) as percentage_category
from pizza_sales
	/*where date_part('month',order_date) = 2*/--lọc theo tháng
group by pizza_category;
--theo size
select pizza_size,SUM(total_price) as total_revenue, CAST(SUM(total_price)*100 /(select sum(total_price)from pizza_sales) as decimal(10,2)) as percentage_category
from pizza_sales
group by pizza_size;

--top5 sản phẩm bán chạy theo revenue, quantity, orders
SELECT distinct pizza_name from pizza_sales
--quantity	
WITH ranked_sales AS (
    SELECT 
        pizza_name,
        SUM(quantity) AS total_quantity,
        RANK() OVER (ORDER BY SUM(quantity) DESC) AS top_rank
    FROM pizza_sales
    GROUP BY pizza_name
)
SELECT pizza_name, total_quantity, top_rank
FROM ranked_sales
WHERE top_rank <= 5;
--revenue
WITH ranked_sales AS (
    SELECT 
        pizza_name,
        SUM(total_price) AS total_revenue,
        RANK() OVER (ORDER BY SUM(total_price) DESC) AS rank
    FROM pizza_sales
    GROUP BY pizza_name
)
SELECT pizza_name, total_revenue
FROM ranked_sales
WHERE rank <= 5;

--orders
WITH ranked_sales AS (
    SELECT 
        pizza_name,
        count(distinct order_id) as total_orders,
        RANK() OVER (ORDER BY count(distinct order_id) DESC) AS rank
    FROM pizza_sales
    GROUP BY pizza_name
)
SELECT pizza_name, total_orders
FROM ranked_sales
WHERE rank <= 5;

--bottom 5 sản phẩm bán tệ nhất theo revenue,quantity,orders
--revenue
with bottom_sales as (
	select pizza_name,
	sum(total_price) as total_revenue,
	rank() over (order by sum(total_price) ASC) as bottom_rank
	FROM pizza_sales
	group by pizza_name
)
SELECT  pizza_name, total_revenue,bottom_rank
FROM bottom_sales
WHERE bottom_rank<=5;
--quantity
with bottom_sales as (
	select pizza_name,
	sum(quantity) as total_quantity,
	rank() over (order by sum(quantity) ASC) as bottom_rank
	from pizza_sales
	group by pizza_name
)
select pizza_name,total_quantity,bottom_rank
from bottom_sales
where bottom_rank <=5;
--orders
with bottom_sales as (
	select  pizza_name,
	count(distinct order_id) as total_orders,
	rank() over (order by count(distinct order_id) ASC) bottom_rank
	from pizza_sales
	group by pizza_name
)
select pizza_name,total_orders,bottom_rank
from bottom_sales
where bottom_rank <=5