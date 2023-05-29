/* 1 2 4 7 11 16 22 */
with cte_seq1 (n, m) as (
	select 1, 1
	union all 
	select n+1, m + n from cte_seq1 where n < 10
)
select m from cte_seq1;

/* 1 4 9 16 25 36 */
with cte_seq2 (n,m) as (
    select 1, 1 
	union all
	select n+2, n+2+m from cte_seq2 where n <10
)
select m from cte_seq2;

/* Factorial of n
	n = 2, 1.2 = 2
	n = 3, 1.2.3 = 6
	n = 4, 1.2.3.4 = 24
	n = 5, 1.2.3.4.5 = 120
*/
with cte_fact (n, m) as (
	select 1,1 
	union all
	select n+1,(n+1)*m from cte_fact where n < 5
)
select m from cte_fact;

/* Fibonacci series
	1 1 2 3 5 8 13 21 34 55
*/
with cte_fib (i, n, m) as (
	select 1,1,1
	union all
	select i+1, m,n+m from cte_fib where i<10
)
select m from cte_fib

/* Display the hierachy of a Employee table
   Data is derived from table Employee in NorthWind database*/
drop table if exists Employees
create table Employees
(
    [EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[ReportsTo] [int] NULL,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([EmployeeID] ASC))

alter table Employees  add constraint [FK_Employees_Employees] foreign key([ReportsTo])
references Employees ([EmployeeID])

insert into Employees (FirstName, LastName, Title, TitleOfCourtesy,ReportsTo)
values ('Nancy','Davolio','Sales Representative','Ms.','2'),
   	   ('Andrew','Fuller','Vice President, Sales','Dr.',NULL),
	   ('Janet','Leverling','Sales Representative','Ms.','2'),
       ('Margaret','Peacock','Sales Representative','Mrs.','2'),
	   ('Steven','Buchanan','Sales Manager','Mr.','2'),
	   ('Michael','Suyama','Sales Representative','Mr.','5'),
	   ('Robert','King','Sales Representative','Mr.','5'),
	   ('Laura','Callahan','Inside Sales Coordinator','Ms.','2'),
	   ('Anne','Dodsworth','Sales Representative','Ms.','5')

select * from Employees;

/*Display the employee hierachy using CTE recursive*/

with cte_employees as (
	select EmployeeID, FirstName + ' ' + LastName as [Name], Title, ReportsTo from Employees where ReportsTo is NULL
	union all
	select e1.EmployeeID, e1.FirstName + ' ' + e1.LastName as [Name], e1.Title, e1.ReportsTo from Employees e1  
	       inner join cte_employees e2 on e1.ReportsTo = e2.EmployeeID

)

select * from cte_employees