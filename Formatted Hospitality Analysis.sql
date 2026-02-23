create database project;
use project;
show databases;
show tables;

-- 1.KPI Total Revenue
select Total_Revenue from(
select sum(revenue_realized) as Revenue, 
case when sum(revenue_realized)>=100000 then concat(format(sum(revenue_realized)/100000,2)," M")
else format(sum(revenue_realized),0) end as Total_Revenue from fact_bookings)a;

-- 2.KPI Total Bookings
select Total_Bookings from(
select count(booking_id) as Bookings,
case when count(booking_id)>=1000 then concat(format(count(booking_id)/1000,0)," K")
else format(count(booking_id),0) end as Total_Bookings from Fact_bookings)a;

-- 3.Occupancy Rate
select concat(format(sum(successful_bookings)/sum(capacity)*100,2), "%") as Occupancy from Fact_aggregated_Bookings;

-- 4.Cancellation Rate
select concat(format((sum(case when Booking_status = "Cancelled" then 1 else 0 end)/Count(*)*100),2) ,"%")as Cancellation_Rate from fact_Bookings;

-- 5.Utilize Capacity
select round(SUM(Successful_Bookings) * 1.0 /NULLIF(SUM(Capacity), 0) 
*SUM(Capacity)) AS utilize_capacity
FROM fact_aggregated_bookings;

-- 1.WEEKDAY VS WEEKEND TREND
select day_type,Total_bookings,Total_Revenue from(
select a.day_type,count(b.booking_id)as bookings,sum(b.revenue_Realized) as Revenue,
case when count(booking_id)>=1000 then concat(format(count(booking_id)/1000,1)," K")
else format(count(booking_id),0) end as Total_Bookings,
case when sum(b.revenue_Realized)>=100000 then concat(format(sum(b.revenue_Realized)/100000,2)," M")
else format(sum(b.revenue_Realized)/100000,0) end as Total_Revenue
from dim_date as a 
left join fact_bookings as b
on DATE_FORMAT(STR_TO_DATE(a.date, '%d-%b-%y'),'%Y-%m-%d')= b.check_in_date
group by day_type order by total_bookings desc)a;

-- 2.REVENUE BY CLASS
select room_class,Total_Revenue from(
select a.room_class,sum(b.revenue_realized) as Revenue,
case when sum(b.revenue_Realized)>=100000 then concat(format(sum(b.revenue_Realized)/100000,2)," M")
else format(sum(b.revenue_Realized)/100000,0) end as Total_Revenue
from dim_rooms as a
right Join fact_bookings as b
on a.room_id = b.room_category
group by room_class order by Revenue desc)a;

-- 3.REVENUE BY CITY & HOTEL
select city,Property_name,Total_Revenue from(
select a.city,a.property_name,sum(b.revenue_realized) as Revenue,
case when sum(b.revenue_Realized)>=100000 then concat(format(sum(b.revenue_Realized)/100000,2)," M")
else format(sum(b.revenue_Realized)/100000,0) end as Total_Revenue from dim_hotels as a
right Join fact_bookings as b
on a.property_id = b.property_id
 group by city,property_name order by city)a;
 
 -- 4.BOOKING STATUS
 select booking_status,Total from(
 select distinct booking_status,count(booking_id) as Result,
case when count(booking_id)>=1000 then concat(format(count(booking_id)/1000,1)," K")
else format(count(booking_id),0) end as Total
 from fact_bookings
 group by booking_status)a;
 
 -- 5.WEEKLY TREND
 alter table dim_date
rename column `week no` to week_no;

select week_no,Total_bookings,Total_Revenue from(
select distinct a.week_no,count(b.booking_id) as bookings,sum(b.revenue_realized) as Revenue,
case when count(booking_id)>=1000 then concat(format(count(booking_id)/1000,1)," K")
else format(count(booking_id),0) end as Total_Bookings,
case when sum(b.revenue_Realized)>=100000 then concat(format(sum(b.revenue_Realized)/100000,2)," M")
else format(sum(b.revenue_Realized)/100000,0) end as Total_Revenue
 from dim_date as a left join fact_bookings as b
 on DATE_FORMAT(STR_TO_DATE(a.date, '%d-%b-%y'),'%Y-%m-%d')= b.check_in_date
 group by week_no order by week_no)a;