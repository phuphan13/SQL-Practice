-- Example 1: Display an arithmetic sequence  1 2 4 7 11 16 22 29 37 46
with cte_sequence (n1, n2) as (
	select 1, 1
	union all 
	select n1 + 1, n1 + n2 from cte_sequence where n1 < 10
)
select n2 from cte_sequence;

--Example 2: Display a fibonacci sequence 1 1 2 3 5 8 13 21 34 55
with cte_fibonacci (f1, f2) as (
	select 0, 1
	union all
	select f2, f1 + f2 from cte_fibonacci where f1 + f2 <= 55
)
select f2 from cte_fibonacci;

-- Example 3: Dispaly the factorial of n
with cte_factorial (n1, n2) as (
	select 1, 1 
	union all
	select n1 + 1,(n1 + 1) * n2 
	from cte_factorial where n1 < 10
)
select n2 from cte_factorial;


-- Example 4: Sum of all digits of a number
declare @num int = 123456;

with cte_sum (n, [sum]) as (
	select @num, 0
	union all
	select n / 10, (n % 10) + [sum] 
	from cte_sum where n > 0
)
select [sum] 
from cte_sum where n = 0;

-- Example 6: Triangle of stars 
with cte_triangle as (
	select 1 as n, cast('*' as nvarchar(10)) as pattern
	union all
	select n +1, cast(pattern + '*' as nvarchar(10)) from cte_triangle where n < 10
)
select * from cte_triangle;

-- Example 7: Display the hierachy of a Employee list 
drop table if exists Employee;
create table Employee
(   EmpID int identity(1,1),
	EmpName nvarchar(10),
	Position nvarchar(10),
	Department nvarchar(20),
	MgrID int,
    constraint PK_EmpID Primary key clustered (EmpID asc))

alter table Employee  add constraint FK_EmpID foreign key(MgrID) references Employee (EmpID);

insert into Employee values ('John','Director','Management',null),
                            ('Ross','Analyst','Sales',1),
							('Edith','Manager','Technology',1),
                            ('Olivia','Manager','Finance',1),
							('George','Clerk','Sales',2),
							('Anne','Clerk','Sales',2),
							('Tony','Dev','Technology',3),
							('Daniel','UX','Technology',3),
							('Ethan','Code','Technology',7),
							('Mark','Analyst','Finance',4),
							('Adam','Test','Technology',7);

--select * from Employee;

with cte_employee as (
	select EmpID, EmpName, Position, Department, 0 as depth,
	       cast(empName as nvarchar(50)) as Hierarchy, 
	       cast(EmpID as nvarchar(20)) as RecursivePath
	from Employee where MgrID is NULL
	union all
	select e1.EmpID, e1.EmpName, e1.Position, e1.Department, depth + 1, 
	       cast(space(depth*5) + '|_' +  e1.EmpName as nvarchar(50)), 
		   cast(concat(e2.RecursivePath,':', e1.EmpID) as nvarchar(20))
	from Employee e1 inner join cte_employee e2 on e1.MgrID = e2.EmpID
)
select EmpID, Hierarchy, Position, Department 
from cte_employee 
order by RecursivePath;

--Example 8: Calculate Project critical path and duration
drop table if exists Project;
create table Project (
	Activity nvarchar(1),
	Predecessor nvarchar(1),
	Duration int
);

-- Sample data 1
insert into Project values ('A',null,3),('B',null,4),('C','A',4),('D','A',5),
                           ('E','A',2),('F','C',3),('H','C',7),('H','D',7),
						   ('H','E',7),('G','B',2),('I','H',6),('I','G',6),
						   ('K','F',3),('K','I',3);

/* Sample data 2
insert into Project values ('A',null,10),('B',null,5),('C','A',6),('D','A',8),
                           ('E','B',12),('E','C',12),('F','D',7),('F','E',7),
						   ('G','D',4),('G','E',4),('H','F',2),('I','G',1); */


--select * from Project;

with cte_project as (
	select Activity, Predecessor, Duration, cast(Activity as nvarchar(20)) as [Path] 
	from Project where Predecessor is null
	union all 
	select p.Activity, p.Predecessor, c.Duration + p.Duration, cast(c.[Path]+'-'+p.Activity as nvarchar(20)) as [Path]  
	from cte_project c inner join Project p on p.Predecessor = c.Activity 
)	

select Activity, Predecessor, [Path], max(Duration) as Duration 
from cte_project
group by Activity, Predecessor, [Path];


-- Example 9: Loan repayment 
drop table if exists Loan;
create table Loan  (
	LoanID nvarchar(1),
	Method int,
	Amount float,
	Schedule int,
	APR1 float, 
	APR2 float
	)
insert into Loan values ('A',1,36000,48,8.5,0), /*Loan A, 36000, equal monthly total payment, 48 months, annual rate 8.5% */
                         ('B',2,20000,36,8.0,10.0); /*Loan B 20000, equal montly priciple payment, 36 months, annual rate 8.0% for first 12 months, then 10.0% */

with cte_loan as (
	select LoanID, Term = 0,
	       Payment = cast(0 as float), 
		   Principle = cast(0 as float), 
	       Interest = cast(0 as float), 
		   Balance = round(cast(Amount as float),2), 
		   Pmt = case when Method = 1 then round(Amount*R1*power(1+R1,Schedule)/(power(1+R1,Schedule)-1),2) --calculate equal monthly payment
		              else 0 end,
		   Prn = case when Method = 2 then round(cast(Amount/Schedule as float), 2) -- calculate equal pricipal payment
		         else 0 end, 
		   Method, R1, R2, Schedule 
	from Loan cross apply (select R1 = APR1/12/100, R2 = APR2/12/100) X
	union all
    select LoanID, Term + 1, 
	       Payment = case when Method = 1 then Pmt 
		                  else Prn + case when Term <= 12 then round(R1*Balance, 2) 
			                              else  round(R2*Balance,2) end end,  
           Principle = case when Method = 1 then round(Pmt-R1*Balance,2)
		                    else Prn end,
		   Interest = case when Method = 1 then round(R1*Balance,2) 
                           else case when Term <= 12 then round(R1*Balance, 2)
		                             else round(R2*Balance,2) end end,
		   Balance = Balance - case when Method = 1 then round(Pmt-R1*Balance,2)
		                            else Prn end,
		   Pmt, Prn, Method, R1, R2, Schedule
    from cte_loan 
	where Term < Schedule
)
select LoanID, Term, Payment, Principle, Interest, Balance 
from cte_loan 
order by LoanID 
option(maxrecursion 300);


-- Example 10: Shortest path between 2 nodes using BFS 
drop table if exists Graph;
create table Graph (
	node_from char, 
	node_to char,
	distance int)

insert into Graph values('A','B',4),('A','C',2),('B','C',1),('B','D',5),
                        ('C','D',8),('C','E',10),('D','E',2),('D','F',8),
						('E','F',5);
insert into Graph select node_to, node_from, distance from Graph; 
	
--select * from Graph;

declare @from char ='A';
declare @to char='F';

with cte_path as (
	select node_from, node_to, distance, cast(node_from + ',' + node_to as nvarchar(20)) as [path] 
	from Graph where node_from = @from
	union all
	select g.node_from, g.node_to, g.distance + c.distance, cast(c.[path] + ',' + g.node_to as nvarchar(20))
	from cte_path c inner join Graph g on c.node_to = g.node_from
	where g.node_from <> @to and g.node_to <> @from and charindex(g.node_to, c.[path]) = 0 
)

/*Display all the paths and shortest path is the first one*/
select [path], distance 
from cte_path 
where charindex(@to,cte_path.[path]) <> 0 
order by distance;