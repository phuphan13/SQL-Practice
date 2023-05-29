/*Purpose: list all sales by month, city and year in tabulation format*/

drop table if exists Product;

create table Product (
	ProductID varchar(50), 
	City varchar(50), 
	Quantity int, 
	[Year] int, 
	[Month] int
);

insert into Product values  ('iPhone','Sydney', 4, 2022, 1),
							('iPhone','Sydney', 3, 2022, 1),
							('Fridge','Sydney', 6, 2022, 1),
							('Television','Melbourne', 2, 2023, 1),
							('iPhone','Sydney', 8, 2022, 2),
							('Fridge','Melbourne', 2, 2023, 3),
							('iPhone','Sydney', 3, 2022, 7),
							('Fridge','Melbourne', 2, 2023, 12),
							('Television','Melbourne', 2, 2022, 1),
							('Fridge','Sydney', 8, 2023, 11),
							('Television','Melbourne', 5, 2023, 7),
							('Fridge','Melbourne', 9, 2023, 2),
							('iPhone','Sydney', 7, 2023, 8),
							('iPhone','Melbourne', 3, 2022, 2),
							('iPhone','Melbourne', 4, 2023, 10);


select * from Product;

/*main query using CTE, Grouping by and pivot*/

with cte1 as (select [Year], City, ProductID, [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
              from (select [Year], City, ProductID, Quantity,[Month] from Product) as Tbl  
                           pivot (sum(Quantity) for [Month] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) as PivotTbl
		      )
,cte2 as (
	select [Year], City, ProductID,  sum(isnull([1],0))[Jan],sum(isnull([2],0))[Feb],sum(isnull([3],0))[Mar],sum(isnull([4],0))[Apr],
                                     sum(isnull([5],0))[May],sum(isnull([6],0))[Jun],sum(isnull([7],0))[Jul],sum(isnull([8],0))[Aug],
									 sum(isnull([9],0))[Sep],sum(isnull([10],0))[Oct],sum(isnull([11],0))[Nov],sum(isnull([12],0))[Dec]
    from cte1 group by grouping sets (([Year], City, ProductID),([Year],City),([Year]),())
	)

select isnull(convert(nvarchar(20),[Year]),'Total')[Year],
       isnull(isnull(City,'Total - ' + convert(varchar(20),[Year])),'')[City], 
	   isnull(isnull(ProductID, 'Total - '+city + ' - '+convert(varchar(20),[Year])),'')[ProductID],
       [Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec], 
	   [Jan]+[Feb]+[Mar]+[Apr]+[May]+[Jun]+[Jul]+[Aug]+[Sep]+[Oct]+[Nov]+[Dec] as  [YTD]
	   from cte2

/*More about SQL Pivot refer link below 
https://learn.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-ver16
*/