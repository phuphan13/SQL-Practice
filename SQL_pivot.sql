/*Purpose: list all sales by month, city and year in tabulation format*/

drop table if exists Product;

create table Product (
	Product varchar(50), 
	City varchar(50), 
	Quantity int, 
	[Year] int, 
	[Month] int
);

insert into Product values  ('iPhone','Sydney', 4, 2022, 1),
							('iPhone','Sydney', 3, 2022, 1),
							('Laptop','Sydney', 6, 2022, 1),
							('eReader','Melbourne', 2, 2023, 1),
							('iPhone','Sydney', 8, 2022, 2),
							('Laptop','Melbourne', 2, 2023, 3),
							('iPhone','Sydney', 3, 2022, 7),
							('Laptop','Melbourne', 2, 2023, 12),
							('eReader','Melbourne', 2, 2022, 1),
							('Laptop','Sydney', 8, 2023, 11),
							('eReader','Melbourne', 5, 2023, 7),
							('Laptop','Melbourne', 9, 2023, 2),
							('iPhone','Sydney', 7, 2023, 8),
							('iPhone','Melbourne', 3, 2022, 2),
							('iPhone','Melbourne', 4, 2023, 10);

select * from Product;

/*First scenario */
select City, [Year], isnull([iPhone],0)[iPhone],isnull([Laptop],0)[Laptop],isnull([eReader],0)[eReader]
from (select Product, City,[Year], Quantity from Product) as tb1 
     pivot (sum(Quantity) for Product in ([iPhone],[Laptop],[eReader])) as tb2 
order by City, [Year];


/* Second scenario */
with cte1 as 
          (select [Year], City, Product,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
           from (select [Year], City, Product, Quantity,[Month] 
			     from Product) as Tbl  
                 pivot (sum(Quantity) for [Month] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) as PivotTbl
		  )
,cte2 as 
        (select [Year], City, Product, sum(isnull([1],0))[Jan],sum(isnull([2],0))[Feb],
				                       sum(isnull([3],0))[Mar],sum(isnull([4],0))[Apr],
									   sum(isnull([5],0))[May],sum(isnull([6],0))[Jun],
								 	   sum(isnull([7],0))[Jul],sum(isnull([8],0))[Aug],
									   sum(isnull([9],0))[Sep],sum(isnull([10],0))[Oct],
								 	   sum(isnull([11],0))[Nov],sum(isnull([12],0))[Dec]
		 from cte1 
	     group by grouping sets (([Year], City, Product),([Year],City),([Year]),())
	)
select isnull(convert(nvarchar(20),[Year]),'Total')[Year],
       isnull(isnull(City,'Total - ' + convert(varchar(20),[Year])),'')[City], 
	   isnull(isnull(Product, 'Total - '+city + ' - '+convert(varchar(20),[Year])),'')[Product],
       [Jan],[Feb],[Mar],[Jan]+[Feb]+[Mar] as Q1,
	   [Apr],[May],[Jun],[Apr]+[May]+[Jun] as Q2,
 	   [Jul],[Aug],[Sep],[Jul]+[Aug]+[Sep] as Q3,
	   [Oct],[Nov],[Dec],[Oct]+[Nov]+[Dec] as Q4, 
	   [Jan]+[Feb]+[Mar]+[Apr]+[May]+[Jun]+
	   [Jul]+[Aug]+[Sep]+[Oct]+[Nov]+[Dec] as YTD
	   from cte2;


/* Dynamic pivot query */

/* For new products added */

insert into Product values  ('Headphone','Sydney', 7, 2023, 5),
						    ('Headphone','Melbourne', 8, 2023, 2),
							('Tablet','Sydney',8,2023,2),
							('Tablet','Melbourne',8,2023,4);

select * from Product;
				
/*Create a dynamic pivot query*/

declare @listColumns as nvarchar(MAX)  ='',
	    @pivotColumns as nvarchar(MAX) ='',
		@pivotQuery as nvarchar(MAX) ='';

select @listColumns = @listColumns + ',isnull(['+ Product +'],0) as ' + Product 
from (select distinct Product from Product) as Tbl1

select @pivotColumns = @pivotColumns + '['+ Product+'],' 
from (select distinct Product from Product) as Tbl2

select @pivotColumns = left(@pivotColumns, len(@pivotColumns)-1)

select @pivotQuery = N'select City, [Year]' + @listColumns + 
                     ' from (select Product, City, [Year], Quantity from Product) as tb1 
					   pivot (sum(Quantity) for Product in ('+@pivotColumns+')) as tb2 
					   order by City, [Year] ' 
					          	
exec sp_executesql @pivotQuery;

