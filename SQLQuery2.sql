 select
   Product.ProductKey,
   StockTxnDate,												
   sum(StockOnHand) as SOHQty,
   0 as BOQQty,
   '' StockStatus,
   0 as StockStatusCount,
   '' as BackorderStatus,
   0 as BackorderStatusCount,
   0 as SOHCost,
   0 as LostSalesValue,
   0 as OverStockAmount,
   0 as OverStockCost
  from
   Product inner join
   ProductInventory on Product.ProductKey = ProductInventory.ProductKey inner join
   ProductSubcategory  on Product.ProductSubcategoryKey = ProductSubcategory.ProductSubcategoryKey 
  where	
   StockOnHand>0 and
   StockTakeFlag='Y'
  group by
   Product.productkey,
   StockTxnDate
 
 UNION ALL

 select
   Product.ProductKey,
   StockTxnDate,												
   0 as SOHQty,
   sum(BackOrderQty) as BOQQty,
   '' StockStatus,
   0 as StockStatusCount,
   '' as BackorderStatus,
   0 as BackorderStatusCount,
   0 as SOHCost,
   0 as LostSalesValue,
   0 as OverStockAmount,
   0 as OverStockCost
  from
   Product inner join
   ProductInventory on Product.ProductKey = ProductInventory.ProductKey inner join
   ProductSubcategory  on Product.ProductSubcategoryKey = ProductSubcategory.ProductSubcategoryKey
  where	
   StockOnHand>0 and
   StockTakeFlag='Y'
  group by
   Product.productkey,
   StockTxnDate

UNION ALL 

 SELECT
   ProductKey,
   StockTxnDate,									
   0 as SOHQty,
   0 as BOQQty,
   StockStatus,
   count(StockStatus) as StockStatusCount,
   '' as BackorderStatus,
   0 as BackorderStatusCount,
   0 as SOHCost,
   0 as LostSalesValue,
   0 as OverStockAmount,
   0 as OverStockCost
from
(
 select
	Product.ProductKey,
	StockTxnDate,
	case
		when StockOnHand>=Product.ReorderPoint then 'Stock Level OK'
		when StockOnHand=0 and BackOrderQty>0 then 'Out of Stock - Back Ordered'
		when (StockOnHand < Product.ReorderPoint) and BackOrderQty>0 then 'Low Stock - Back Ordered'
		when BackOrderQty=0 and (StockOnHand<= Product.ReorderPoint) then 'Reorder Now'
	end as StockStatus
 from
   Product inner join
   ProductInventory on Product.ProductKey = ProductInventory.ProductKey inner join
   ProductSubcategory  on Product.ProductSubcategoryKey = ProductSubcategory.ProductSubcategoryKey 
 where
  StockOnHand>0 and
  StockTakeFlag='Y' ) as dtStockStatus
 group by
   ProductKey,
   StockStatus,
   StockTxnDate


UNION ALL

SELECT
   ProductKey,
   StockTxnDate,								
   0 as SOHQty,
   0 as BOQQty,
   '' StockStatus,
   0 as StockStatusCount,
   BackorderStatus,
   count(BackorderStatus) as BackorderStatusCount,
   0 as SOHCost,
   0 as LostSalesValue,
   0 as OverStockAmount,
   0 as OverStockCost
 FROM
(
  select
	Product.ProductKey,
	StockTxnDate,
	case
		when BackOrderQty >0 and BackOrderQty <=10 then 'Up to 10 on order'
		when BackOrderQty >10 and BackOrderQty <=20 then 'Up to 20 on order'
		when BackOrderQty >20 and BackOrderQty <=40 then 'Up to 40 on order'
		when BackOrderQty >40 and BackOrderQty <=60 then 'Up to 60 on order'
	else
		'+ 60 on order'
	end as BackorderStatus
  from
 Product inner join
   ProductInventory on Product.ProductKey = ProductInventory.ProductKey inner join
   ProductSubcategory  on Product.ProductSubcategoryKey = ProductSubcategory.ProductSubcategoryKey 	
  where
	BackOrderQty > 0 and
    StockTakeFlag='Y'
) as dtBackorderstatus 
group by
ProductKey,
BackorderStatus,
StockTxnDate

UNION ALL

select
   Product.ProductKey,
   StockTxnDate,												
   0 as SOHQty,
   0 as BOQQty,
   '' StockStatus,
   0 as StockStatusCount,
   '' as BackorderStatus,
   0 as BackorderStatusCount,
   sum(StockOnHand * UnitCost) as SOHCost,
   0 as LostSalesValue,
   0 as OverStockAmount,
   0 as OverStockCost
  from
   Product inner join
   ProductInventory on Product.ProductKey = ProductInventory.ProductKey inner join
   ProductSubcategory  on Product.ProductSubcategoryKey = ProductSubcategory.ProductSubcategoryKey 
  where	
   StockOnHand>0 and
   StockTakeFlag='Y'
  group by
   Product.productkey,
   StockTxnDate