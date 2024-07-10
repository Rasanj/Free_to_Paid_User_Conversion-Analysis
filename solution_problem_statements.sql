use db_course_conversions;
select * from student_engagement;
select * from student_info;
select * from student_purchases;

-- EDA of the given table. 
select student_id, count(student_id) as qty from student_engagement 
group by student_id
order by qty desc; -- repeat users

select student_id ,count(student_id) as qty from student_info group by student_id order by qty desc;

select student_id,count(student_id) as qty from student_purchases group by student_id order by qty desc; -- repeat users

-- Creating required view based on problem statement requirement

Create view ref_tbl1 as
select si.student_id , si.date_registered as registration_date,
se.first_watch_date, sp.first_purchase_date, -- first puchase and first watch date 
datediff(se.first_watch_date, si.date_registered) as diff_watch_reg, -- difference between watch_date and registration_date
datediff(sp.first_purchase_date, se.first_watch_date) as diff_purch_watch --  difference between purchase_date and watch_date
from student_info si 
left Join
(select student_id, min(date_watched) as first_watch_date from student_engagement
group by student_id ) se
on si.student_id =se.student_id
left join
(select student_id , min(date_purchased) as first_purchase_date from student_purchases group by student_id) sp
on si.student_id =sp.student_id
where first_watch_date is not null and first_purchase_date is not null;

-- check view table 

select * from ref_tbl;

 -- Problem Statements ::
-- conversion rate for user who watched videos ( who atleast watched a video before first purchase) -- 12.9percent 

select ((count(first_purchase_date)/count(first_watch_date)) * 100) as conversion_rate
 from ref_tbl where diff_purch_watch >= 0 or diff_purch_watch is null;


-- Average Duration Between Registration and First-Time Engagement -- 3.9 days
select round(avg(diff_watch_reg),2) as avg_duration from ref_tbl;

-- Average Duration Between First-Time Engagement and First-Time Purchase  -- 26.24 days
select avg(diff_purch_watch) as avg_duration from ref_tbl
where diff_purch_watch >= 0 ;

-- Renewed program the second month 
select * from ref_tbl;
with CTE as (
select student_id , date_purchased, min(date_purchased)over(partition by student_id) as first_purchase 
from student_purchases),
ref_tb as 
(select student_id ,date_purchased,first_purchase
from CTE where date_purchased = Date_add(first_purchase,Interval 1 Month))
select count(*) from ref_tb;


