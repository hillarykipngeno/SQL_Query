--using case in sql

--. Write the sql statement to list employees by name, salary and the message 'underpaid' if their salary is less than 2000 
	and 'overpaid' if their salary is greater than 3000 and 'OK' if their salary is between 2000 and 3000. 

select first_name||' '||last_name as name,salary,
case when salary<2000 then 'underpaid'
when salary>3000 then 'overpaid'
else 'ok' end
from employees;

--Using operand in a condition example
--. Write a query in SQL to display the details of jobs which minimum salary is greater than 9000.
 
select * from jobs
where min_salary>9000;


--retrieving second row with ties

--1. Write a query to display all the information for those employees whose id is any id who earn the second highest salary.

select * 
from employees
order by salary desc
offset 1
fetch next 1 row with ties;


--Using aggregate functions as window functions
--sum and count
select department_id, first_name, salary, avg(salary) over( partition by department_id order by salary rows between unbounded preceding and unbounded  following) as "average salary",
count(salary) over(partition by department_id order by salary rows between unbounded preceding and unbounded following) as "count",
sum(salary) over(partition by department_id order by salary rows between unbounded preceding and unbounded following) as "sum"
from employees;

--count avg, min,max
select first_name, last_name, department_id, salary,
count(employee_id) over(partition by department_id order by salary rows between unbounded preceding and unbounded following ) as employeecount,
avg(salary) over(partition by department_id order by salary rows between unbounded preceding and unbounded following ) as avgsalary,
min(employee_id) over(partition by department_id order by salary rows between unbounded preceding and unbounded following ) as minsalary,
max(employee_id) over(partition by department_id order by salary rows between unbounded preceding and unbounded following ) as maxsalary
from employees;

--row_number
select department_id, first_name, last_name, salary, row_number() over(partition by department_id order by salary ) as rownum
from employees;

--- using sum aggregate window function to calculate running total
select first_name, last_name, salary,
sum(salary) over(order by employee_id) as runnigtotal
from employees;
select department_id, first_name, last_name, salary,
ntile(2) over(partition by department_id order by salary desc)
from employees;

--Lead andLag
 select first_name, last_name, salary,
 lead(salary,1,-1) over(order by salary desc) as "lead",
 lag(salary, 2,-1) over(order by salary desc) as "lag"
  from employees;
  
  --First_value and Last_value
 select department_id, first_name, last_name,salary,
 first_value(first_name) over(partition by department_id order by salary),
 last_value(first_name) over(partition by department_id order by salary)
 from employees;


--with joins
select e.*,j.job_title, min(e.salary) over(partition by department_id) as minsalary,
 max(e.salary) over(partition by department_id) as maxsalary,
 avg(e.salary) over(partition by department_id) as avgsalary
 from
 employees e
 join
 jobs j using (job_id)
 where job_title in('Sales Representative', 'Stock Clerk');

--CTE with sum() aggregate window function
--write a SQL query to find those employees whose salaries exceed 50% of their department's total salary bill. Return first name, last name, Salary, D_Total,Salary;
with result as(
select first_name, last_name, salary, sum(salary) over(partition by department_id 
order by salary rows between unbounded preceding and unbounded following) as d_total
from employees)
select first_name, last_name, salary, d_total from result where salary>(d_total*0.5);



 
--using CTE with window functions
--row_number
with result as
(select *, row_number() over(partition by department_id order by salary ) as rownum
from employees)
select * from result where rownum=2 and phone_number is null;

--Rank and Dense_rank
with employeescte as
(
select first_name, last_name, salary,
rank() over(order by salary) as "Rank",
dense_rank() over(order by salary desc) as "Dense_Rank"
from employees
)
select first_name, last_name, salary from employeescte
where "Dense_Rank"=2;

--finding the mode salary using analytics and window fuctions
 
 with result as(
select * ,
count(salary) over(partition by salary order by salary rows between unbounded preceding and unbounded following) as salary_mode
from employees) 
select * from result where salary_mode=(select max(salary_mode) from result); 

--retriving the employees who were hired before and after john chen in a single row
with result as
(select first_name, last_name, hire_date,
lead(first_Name,1)over(order by hire_date) as dlead,
lead(hire_date,1)over(order by hire_date) as dlead_hire_date,
lag(first_name,1)over(order by hire_date) as dlag,
lag(hire_date,1)over(order by hire_date) as dlag_hire_date
from employees)
select * from result where first_name='John' and last_name='Chen';

--Windows analytics: For all those employees whose salary is below their departments average salary , List the employee details,
	salary and the proposed salary increase in Percentage required to match the respective average.;
	

with result as
        (
        select first_name, last_name, salary,
        round(avg(salary) over(partition by department_id ),2) as avgsalary
        from employees
        )
select *, case when salary< avgsalary then round((((avgsalary-salary)/salary)*100),0)||'%' end as per_inc from result
where salary<avgsalary;

-- Windows analytics: For all those department with more than one employees , list the second highest salary earner per department including the ties. 


with result as(					 
select department_id, first_name, last_name,salary, 
dense_rank() over(partition by department_id order by salary desc) as d_rank,
count(employee_id) over(partition by department_id order by salary desc) as emp_count
from employees
)
select * from result where emp_count>1 and d_rank=2; 



----SQL is a structured query language that is used for managing and retrieving and storing data from database 
--what is the difference between a primary key and a unique key
----the difference between primary key and unique key is that primary key does not allow null values whereas unique key only one null value.
-- Write a sql to show same row from a table twice in the results;

--using unionall
select * from employees
where employee_id=120
union all
(select * from employees
where employee_id=120);


--Write a query to get the details of employees who are managers.
--using joins
SELECT e2.*, j.job_title FROM employees e1 JOIN employees e2 ON e1.manager_id=e2.manager_id
join jobs j on e2.job_id=j.job_id;

select e.*, j.*
from employees e
join
jobs j on e.job_id=j.job_id
where j.job_title like '%Manager';

--using joins wit subquery
select e.*, j.* 
from employees e
join
jobs j on e.job_id=j.job_id
where employee_id in (select manager_id
from employees);

--5. Write a query to get the Job_title  and the salary  of the highest paying job. --(3 amrks)
select j.job_title, e.salary
from employees e
join
jobs j on e.job_id=j.job_id
where e.salary=(select max(salary) from employees);



---Creating a table
create table tblproductsales(
salesman varchar(255) not null,
india int not null,
us int not null,
uk int not null);


--inserting data into a table
insert into tblproductsales(salesman, india, us, uk)values('David', 950, 520, 360);
insert into tblproductsales(salesman, india, us, uk)values('John', 970, 540, 800);

 
--unpivot table with postgress
select c.salesman,t.country, t.salesamount
from tblproductsales c
cross join lateral
(
values('india', c.india),
('us', c.us),
('uk', c.uk)
) as t(country, salesamount);

---pivot table using crosstab in postgress
--retrieving job id with the sum of their salaries in each department as a pivot table

select * from crosstab('select job_id as job,
department_id as department, sum(cast(salary as int)) as salary from employees
group by job_id, department_id order by 1 ', 'values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)' ) as 
(job_id int,department_1 bigint, department_2 bigint,department_3 bigint,
 department_4 bigint,department_5 bigint,department_6 bigint,department_7 bigint,
 department_8 bigint,department_9 bigint,department_10 bigint);
`

--retrieving each department's sum of salary each year as a pivot table
select * from crosstab('select department_id as id, to_char(hire_date, ''YYYY'') as start_year,  
sum(cast(salary as int)) as salary from employees
group by department_id,to_char(hire_date, ''YYYY'') order by 1', 
'values (1991),(1992),(1993),(1994),(1995),(1996),(1997),(1998),(1999)') as
(department int,"1991" bigint, "1992" bigint, "1993" bigint,
 "1994" bigint,"1995" bigint,"1996" bigint,"1997" bigint,
 "1998" bigint,"1999" bigint);
 
 --Using case to create a pivot table 
 
 select
case when country_id='US' then state_province end as US,
case when country_id='UK' then state_province end as UK,
case when country_id='CA' then state_province end as CA,
case when country_id='DE' then state_province end as DE
from locations;
 

 --write a SQL query to find the minimum ,maximum and average salary BY department for those employees whose job is 'SALESMAN' and'CLERK'
 
 select e.first_name, e.last_name, e.salary, d.department_name, m.first_name as "manager name"
 from employees e
 join
 employees m on m.employee_id=e.manager_id
 join
 departments d on e.department_id=d.department_id;
 
 
 ---Using case with select
select first_name,
sum(case when department_id=1 then salary end) as dept_1,
sum(case when department_id=2 then salary end) as dept_2,
sum(case when department_id=3 then salary end) as dept_3,
sum(case when department_id=4 then salary end) as dept_4,
sum(case when department_id=5 then salary end) as dept_5
from employees
group by department_id, first_name;

--concatenating columns
--List the employee name, department_name,salary , city and country_name 
select e.first_name||' '|| e.last_name as name, d.department_name, e.salary, l.city, c.country_name
from
employees e
join
departments d on e.department_id=d.department_id
join
locations l on d.location_id=l.location_id                                                                                                                                                          z
join
countries c on l.country_id=c.country_id;

--List with a copy the details of the employee identified by first_name=Neena , last_name=Kochhar
select * from employees
where first_name='Neena' and last_name='Kochhar'
union all
select * from employees
where first_name='Neena' and last_name='Kochhar';

--Using order by with case.
--List employees details while sorted by the salary starting from the smallest to the highest , while at the same time keeping 
	the President ,Administration Vice President first and second respectively. [ Do not hardcode the job_id ]
	
select e.*, j.* from employees e
join
jobs j on e.job_id=j.job_id 
order by 
        case  when job_title= 'President' then 1 
        when job_title='Administration Vice President' then 2
        else 3 end, salary asc;


select  first_name, department_id from employees;




--  
--List the employee name, department_name,salary , city and country_name 
select   first_name||' '||last_name as name, department_name, salary, city, country_name 
from
employees e 
join
departments d on e.department_id=d.department_id
join
locations l on d.location_id=l.location_id
join
countries c on c.country_id=l.country_id;

--10. List the name[First_Name , Last_name ] of the managers
select e.first_name||' '||e.last_name as name, salary,job_title
from employees e
join
jobs j on e.job_id=j.job_id
where job_title like('%Manager')

--creating a view
create view vwITdept_name as
select employee_id, first_name||' '||last_name as name, salary, department_name
from employees e
join
departments d on e.department_id=d.department_id
where department_name='IT'

select * from vwITdept_name;
select * from employees
order by employee_id;

--updateable views
create view empdetlessalry as
select employee_id, first_name, last_name, hire_date, job_id, manager_id, department_id from employees

update empdetlessalry
set first_name='Hillary' where employee_id= 104 
delete from empdetlessalry where employee_id=104
insert into empdetlessalry values(104,'Bruce', 'Ernest', '1991-05-21', 9, ,103,6)
select * from empdetlessalry
order by employee_id;






