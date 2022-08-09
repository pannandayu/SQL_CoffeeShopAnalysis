alter table transaction_data  
add primary key(transaction_id);

alter table transaction_data
add foreign key(customer_id) references customer_data(customer_id);

alter table outlet_data  
add foreign key(manager) references staff_data(staff_id);

alter table cus  
add foreign key(manager) references staff_data(staff_id);

alter table customer_data 
drop constraint customer_data_pkey;

alter table outlet_data 
alter column manager type integer;

-- Total Sales and Quantity Sold
select sum(quantity) as total_quantity, sum(line_item_amount) as total_sales, count(*) as transaction_count 
from transaction_data;

-- Total Sales and Quantity Sold (Grouped by Promo)
select promo_item_yn, sum(quantity) as total_quantity, sum(line_item_amount) as total_sales 
from transaction_data
group by promo_item_yn
order by promo_item_yn;

-- Total Sales and Quantity Sold (Grouped by Instore)
select instore_yn, sum(quantity) as total_quantity, sum(line_item_amount) as total_sales
from transaction_data
group by instore_yn
order by instore_yn ;

-- Date with Most Sales 
select transaction_date , sum(quantity) as total_quantity, sum(line_item_amount) as total_sales
from transaction_data
group by transaction_date 
order by total_sales desc;

-- Total Sales (Grouped by Product)
select sales.product_id, product, product_category, product_type, total_sales
from product_data pd
join
	(
	select product_id, sum(line_item_amount) as "total_sales"
	from transaction_data td 
	group by product_id
	) as sales
on pd.product_id = sales.product_id
order by total_sales desc;

-- Unsold Products
select pd.product_id, pd.product
from product_data pd 
left join
	(
		select pd.product_id, product, product_category, product_type, total_sales
		from product_data pd
		join
			(
				select product_id, sum(line_item_amount) as "total_sales"
				from transaction_data td 
				group by product_id
			) as sales
		on pd.product_id = sales.product_id
	) as sales2
on pd.product_id = sales2.product_id
where sales2.product_id is null;

-- Highest Performing Staffs
select s.staff_id, concat(sd2.first_name, ' ', sd2.last_name) as full_name, s.total_sales, s.total_quantity, sd2.position  
from
	(
		select staff_id, sum(line_item_amount) as total_sales, sum(quantity) as total_quantity
		from transaction_data td
		group by staff_id
		order by total_sales desc
	) as s
join staff_data sd2 
on s.staff_id = sd2.staff_id
order by total_sales desc;

-- Store Managers
--create table staff2 as
--(
--	select * from staff_data sd 
--);
--alter table staff2 
--alter column "location" type varchar;
--create table outlet2 as
--(
--	select * from outlet_data od 
--);
--alter table outlet2
--alter column manager type varchar;
select staff_id, concat(first_name, ' ', last_name) as full_name, position, location, store_address, store_city
from staff2 s
left join outlet2 o 
on s.staff_id  = o.manager
--left join outlet2 o2 
--on s.staff_id = o2.manager 
where o.sales_outlet_id is not null
;

-- Customer Spending
select c.customer_id, c.total_quantity, c.total_sales, cd.customer_since, cd.loyalty_card_number
from
	(
		select customer_id, sum(quantity) as total_quantity, sum(line_item_amount) as total_sales
		from transaction_data td
		group by customer_id
		order by total_sales desc
	) as c
left join customer_data cd
on c.customer_id = cd.customer_id
order by total_sales desc;

-- Recorded Store Sales
select n.sales_outlet_id, n.total_sales, total_quantity
from
	(
		select sales_outlet_id, sum(line_item_amount) as total_sales, sum(quantity) as total_quantity
		from transaction_data td
		group by sales_outlet_id
	) as n
join outlet_data od
on n.sales_outlet_id = od.sales_outlet_id
order by n.total_sales desc; 
