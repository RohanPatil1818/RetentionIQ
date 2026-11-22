



-- Step-1 

-- Combine both year and convert types safelyy

select Invoice, StockCode, Description, Quantity,
 
   coalesce(
		try_convert(datetime2, InvoiceDate, 120),
		try_convert(datetime2, InvoiceDate, 105)
		) as InvoiceDate,

		try_convert(decimal(10,2), Price) as Price,
		Customer_id, Country, '2009-2010' as SourceSheet
		into dbo.RetailCombined from dbo.[year 2009-2010]

	union all

	select Invoice, StockCode, Description, Quantity,
	coalesce(
			try_convert(datetime2, InvoiceDate, 120),
			try_convert(datetime2, InvoiceDate, 105)
			)as InvoiceDate,
			try_convert(decimal(10,2),Price) as Price,
			Customer_ID, Country, '2010-2011' as SourceSheet
			from dbo.[Year 2010-2011];


-- Step-2
-- Confirm the conversion worked
select count(*) as Total_Rows from dbo.RetailCombined;
select count(*) as Failed_Dates from dbo.RetailCombined where InvoiceDate is null;	
select count(*) as Failed_Prices from dbo.RetailCombined where Price is null;



-- Step- 3
-- Check 1 - Missing customer ID
select count(*) as Missing_CustomerID from dbo.RetailCombined where Customer_ID is null;


-- Check 2 - Negative or zero quantity
select count(*) as Negative_Qty from dbo.RetailCombined where Quantity <= 0;

-- Check 3 - Missing Descriptions
select count(*) as Missing_Description from dbo.RetailCombined where Description is null;

--- Check 4 Exact duplicate rows
select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, 
	count(*) as ExactDupeCunt
from dbo.RetailCombined
group by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
having count(*) > 1;



-- Step-4

-- Deduplicate and produce the final, cleaned table

with Deduped as (
	select *, row_number() over(
	partition by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, COuntry
	order by (select NULL)
	)
	AS RowNum
	from dbo.RetailCombined
)
select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, SourceSheet
into dbo.RetailCleaned            -- created a new cleaned final tabeles 
                                    -- It containes only 1st occurance 
from Deduped
where RowNum = 1;

select * from dbo.RetailCleaned;
