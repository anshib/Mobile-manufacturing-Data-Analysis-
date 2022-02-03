


--1.	List all the states in which we have customers who have bought cellphones from 2005 till today.

select distinct(State) from DIM_LOCATION as s left join FACT_TRANSACTIONS as f on s.IDLocation=f.IDLocation
where f.Date > '01-jan-2005'

--2.	What state in the US is buying more 'Samsung' cell phones?

select top 1 dl.State ,count(*) 'Total count',dmf.Manufacturer_Name 'Model' from DIM_LOCATION [dl],FACT_TRANSACTIONS [f],DIM_MODEL [dm],DIM_MANUFACTURER [dmf] 
where dl.IDLocation=f.IDLocation and dm.IDModel=f.IDModel and dm.IDManufacturer=dmf.IDManufacturer and dmf.Manufacturer_Name like 'Samsung'
group by dl.State , dmf.Manufacturer_Name
order by count(*) desc

--3.	Show the number of transactions for each model per zip code per state.

select dm.IDModel,dm.Model_Name ,dl.ZipCode, dl.State, count(*) 'Number of transactions'  from FACT_TRANSACTIONS f, DIM_MODEL dm, DIM_LOCATION dl
where f.IDLocation=dl.IDLocation and f.IDModel=dm.IDModel
group by dm.Model_Name , dl.ZipCode, dl.State, dm.IDModel
order by dl.State,dl.ZipCode,dm.Model_Name

--4.	Show the cheapest cellphone

select top 1 * from DIM_MODEL
order by Unit_price asc

--5.	Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price

select top 5 dm.IDModel,dm.Model_Name,dmf.Manufacturer_Name, AVG(f.TotalPrice) 'AVG' from DIM_MODEL as dm,DIM_MANUFACTURER as dmf,FACT_TRANSACTIONS as f
where dm.IDModel=f.IDModel and dmf.IDManufacturer=dm.IDManufacturer 
group by dm.IDModel,dm.Model_Name,dmf.Manufacturer_Name
order by 'AVG' desc

--6.	List the names of the customers and the average amount spent in 2009, where the average is higher than 500

select dc.Customer_Name , AVG(f.TotalPrice) as Average_Amount_Spent from DIM_CUSTOMER dc , FACT_TRANSACTIONS f, DIM_DATE dd
where dc.IDCustomer=f.IDCustomer and f.Date=dd.DATE and dd.YEAR=2009
group by dc.Customer_Name
having AVG(f.TotalPrice) > 500 
order by Average_Amount_Spent

--7.	List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010

select top 5 dm.Model_Name, sum(f.Quantity) Qty, dd.YEAR from FACT_TRANSACTIONS f, DIM_MODEL dm, DIM_DATE dd
where f.IDModel=dm.IDModel and f.Date=dd.DATE and dd.YEAR in (select YEAR from DIM_DATE where YEAR = 2008 or YEAR = 2009 or YEAR = 2010)
group by dm.Model_Name,dd.YEAR
order by sum(f.Quantity) desc

--8.	Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

select dmf.Manufacturer_Name,dm.IDModel, dd.YEAR,sum(f.Quantity) 'Total sale' from DIM_MANUFACTURER dmf,DIM_MODEL dm, DIM_DATE dd, FACT_TRANSACTIONS f
where dmf.IDManufacturer=dm.IDManufacturer and dm.IDModel=f.IDModel and f.Date=dd.DATE and YEAR = 2009
group by dmf.Manufacturer_Name,dm.IDModel, dd.YEAR
order by 'Total sale' desc offset 1 rows fetch next 1 rows only

select dmf.Manufacturer_Name,dm.IDModel, dd.YEAR,sum(f.Quantity) 'Total sale' from DIM_MANUFACTURER dmf,DIM_MODEL dm, DIM_DATE dd, FACT_TRANSACTIONS f
where dmf.IDManufacturer=dm.IDManufacturer and dm.IDModel=f.IDModel and f.Date=dd.DATE and YEAR = 2010
group by dmf.Manufacturer_Name,dm.IDModel, dd.YEAR
order by 'Total sale' desc offset 1 rows fetch next 1 rows only


--9.	Show the manufacturers that sold cellphone in 2010 but didn’t in 2009.

select distinct(dmf.Manufacturer_Name)from DIM_MANUFACTURER dmf, DIM_DATE dd, FACT_TRANSACTIONS f, DIM_MODEL dm
where dmf.IDManufacturer=dm.IDManufacturer and f.IDModel=dm.IDModel and dd.DATE=f.Date and dd.YEAR in (2010)
except
select distinct(dmf.Manufacturer_Name) from DIM_MANUFACTURER dmf, DIM_DATE dd, FACT_TRANSACTIONS f, DIM_MODEL dm
where dmf.IDManufacturer=dm.IDManufacturer and f.IDModel=dm.IDModel and dd.DATE=f.Date and dd.YEAR in (2009)

--10.	Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend

select top 100 dc.Customer_Name, AVG(f.TotalPrice) 'Avg Spent', AVG(f.Quantity) 'Avg Quantity', dd.YEAR, (AVG(f.TotalPrice) - LAG(AVG(f.TotalPrice)) 
OVER (PARTITION BY dc.Customer_Name ORDER BY dd.YEAR ASC ))*100/LAG(AVG(f.TotalPrice)) 
OVER (PARTITION BY dc.Customer_Name ORDER BY dd.YEAR ASC )
AS '% OF CHANGE' from DIM_CUSTOMER dc, FACT_TRANSACTIONS f, DIM_DATE dd
where dc.IDCustomer=f.IDCustomer and f.Date=dd.DATE
group by dc.Customer_Name, dd.YEAR
order by 'Avg Spent' desc, 'Avg Quantity' desc


