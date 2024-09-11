use new_schema;

select * from amazon;

-- DATA CLEANING

alter table amazon rename column `customer type` to customer_type;

alter table amazon rename column `product line` to product_line;

alter table amazon rename column `gross income` to gross_income;

set sql_safe_updates = 0;

alter table amazon add column day_name varchar(250);
update amazon set day_name = dayname(date);

update amazon set week_day = 
case
when weekday(Date) = 5 then 'weekend'
when weekday(Date) = 6 then 'weekend'
else 'weekday'
end;

-- 1) what is the count of distinct cities in the dataset ?
select count(distinct city) from amazon;
-- 3

-- 2) For each branch, what is the corresponding city ?
Select branch, city from amazon 
group by branch , city
order by branch;
/* 
A	Yangon
B	Mandalay
C	Naypyitaw 
*/

-- 3) What is the count of distinct product line in dataset ?
Select count(distinct product_line) as product_lines from amazon ;
-- 6

-- 4) Which payment method occurs most frequently ?
select Payment, count(*) as payment_count from amazon 
group by payment
ORDER BY count(*) DESC 
 LIMIT 1; 
-- Ewallet	345

-- 5) Which Product line has the highest sale ?
select product_line, round(sum(total)) as most_selling_product from amazon 
group by product_line
order by sum(total) desc
limit 1; 
-- 	Food and beverages	56145

-- 6) How much revenue genrated each month ?
select month_name, sum(total) as revenue_each_month from amazon
group by month_name
order by sum(total) desc;

-- January	116291.86800000005
-- March	109455.50700000004
-- February	97219.37399999997

-- In which month did the cost_of_goods sold reach its peak ?
select month_name, sum(cogs) as cost_of_goods_sum from amazon
group by month_name
order by Sum(cogs) desc
limit 1;
-- January	110754.16000000002

-- 8) which product_line genrated the hightest revenue ?
select product_line, sum(total) as revenue_productline from amazon
group by product_line
order by sum(total) DESC
limit 1;

-- 9) In which city highest revnue was genrated ?
Select city, sum(total) as city_total from amazon
group by city 
order by sum(total) DESC
limit 1; 
-- Naypyitaw	110568.70649999994

-- 10) Which product line incurred the highest vat ?
alter table amazon rename column `tax 5%` to vat;

select product_line, sum(vat) as vat_productline from amazon 
group by 1
order by sum(vat) desc
limit 1; 
-- Food and beverages	2673.5639999999994

-- 11 ) for each  product_line addd column indicating 'good' if its sales are above average, otherwise bad.
select product_line, sum(total),
case
when sum(total) > (select avg(total) from amazon)  then 'good'
else 'bad'
end as 'Product_remark'
from amazon
group by product_line;

-- 12) Identify the branch that exceeds the average number of product sold
 select branch, sum(quantity) as total_quantitiy from amazon
 group by branch
 having sum(quantity) > (select avg(quantity) from amazon);


# 13  Which product line is most frequently associated with each gender
with product_gender_count as
(
	select Gender, product_line, count(*) as gender_count,
    row_number() over ( partition by Gender ORDER by count(*) desc) as rn
    from amazon
	group by gender, Product_line
)
select gender, product_line, gender_count from product_gender_count 
where rn = 1;


-- 14 Calculate the average rating for each product_line 
select product_line, avg(rating) from amazon
group by product_line
order by avg(rating) desc;


alter table amazon add column time_of_day varchar(20);

update amazon set time_of_day = 
case 
when hour(time) between 6 and 11 then 'GOOD MORNING'
when hour(time) between 12 and 17 then 'GOOD afternoon'
when hour(time) between 18 and 23 then 'GOOD evening'
else 'NIGHT'
END;

#15 count the sales occurence for each time_of_day on every weekday
select time_of_day, week_day, count(total) 
from amazon
group by 1 , 2 
having week_day = 'weekday'; 
/*
GOOD MORNING	weekday	141
GOOD evening	weekday	185
GOOD afternoon	weekday	377
*/


-- 16 Identitfy the customer type contributing the highest revenue
select customer_type, sum(total) from amazon
group by customer_type 
order by sum(Total) limit 1;
-- Normal	158743.30500000005


-- 17 determine the city with the highest VAT
select city, sum(vat) from amazon
group by city
order by sum(vat) desc
limit 1;
-- Naypyitaw	5265.176500000002


-- 18 Identitfy the customer type with the highest VAT payment
select customer_type, sum(vat) from amazon
group by customer_type
order by sum(vat)
limit 1;
-- Normal	7559.205000000003


-- 19 What is the count of distinct customer type in database
select customer_type , count(*) from amazon
group by customer_type;
-- Member	501
-- Normal	499

-- 20 what is the count of distinct payment method in the dataset 
select  Payment, count(*) from amazon
group by payment;
-- Ewallet	345
-- Cash	344
-- Credit card	311


-- 21 which customer type occurs most frequently 
select customer_type , count(*) from amazon
group by customer_type
order by count(*) desc
limit 1;
-- Member	501


-- 22 Identify the customer type with highest purchase frequency 
alter table amazon rename column `Invoice ID` to invoice_id;
select customer_type, count(invoice_id) from amazon 
group by customer_type
order by count(invoice_id) desc
limit 1;
-- Member	501


-- 23 Determine the predominant gender among customers.
select gender, count(gender) from amazon
group by gender
order by count(gender) desc;
-- Male	499
-- Female	501


-- 24 Examine the distribution of genders within each branch.
select Branch, count(gender) from amazon
group by branch;
-- A	340
-- C	328
-- B	332


-- 25 Identify the time of day when customers provide the most ratings.
select time_of_day, count(rating) from amazon
group by time_of_day;
-- GOOD afternoon	528
-- GOOD MORNING	191
-- GOOD eveniG	281


-- 26 Determine the time of day with the highest customer ratings for each branch.
with tod_gender_rating as(
	select time_of_day, branch, sum(rating) as highest_rating,
    row_number() over(partition by branch order by sum(rating) desc) as rn
    from amazon
    group by time_of_day, branch
)
select time_of_day, branch, highest_rating from tod_gender_rating
where rn = 1;
-- GOOD afternoon	A	1305.5000000000005
-- GOOD afternoon	B	1102.7000000000003
-- GOOD afternoon	C	1284.2999999999995


-- 27 Identify the day of the week with the highest average ratings.
select day_name, avg(rating) from amazon
group by day_name
order by avg(rating) desc
limit 1;
-- Monday	7.153599999999999


-- 28 Determine the day of the week with the highest average ratings for each branch.
with branch_rating as (
	select branch, day_name, avg(rating) as avg_rating, 
    row_number() over(partition by branch order by avg(rating) desc) as rn
    from amazon
    group by Branch, day_name
    )
select branch, day_name, avg_rating from branch_rating
where rn=1;    
-- A  Friday	7.3119999999999985
-- B  Monday	7.335897435897434
-- C  Friday	7.278947368421051