use [PORTFOLIO 2];
select * from Sheet1;
-------------------------------------------
--standardize date format
select SaleDate,convert(date,saledate) as 'Date' from Sheet1;

update Sheet1 set SaleDate=convert(date,saledate)   --doesnt work because update commmnad work on data rowsnot on whole column or adding integrity contriant to a column use alter tble command instead
select saledate from Sheet1
--alter table sheet1 add Saledateconverted date
alter table sheet1 ALter column saledate date            ----new format
select saledate from Sheet1

--------------------------------------------
--populate property adress data
select * from Sheet1 where PropertyAddress is null
--selfjoin
select a.ParcelID,a.PropertyAddress,b.parcelid,b.propertyaddress from Sheet1 A ,sheet1 B where A.parcelid=b.parcelid and a.UniqueID <>b.uniqueid
select count([UniqueID ]) from Sheet1 where PropertyAddress is null
select a.ParcelID,a.PropertyAddress,b.parcelid,b.propertyaddress,ISNULL(a.PropertyAddress,b.PropertyAddress) as 'tobereplaced adress' from Sheet1 A ,sheet1 B where A.parcelid=b.parcelid and a.UniqueID <>b.uniqueid and a.PropertyAddress is null  --specify is null a.propertyaddress or b.propertyaddress
select count([UniqueID ]) from Sheet1 where PropertyAddress is null           --not upadated yet 

select * from sheet1

update a set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)  from Sheet1 A ,sheet1 B where A.parcelid=b.parcelid and a.UniqueID <>b.uniqueid and a.PropertyAddress is null        --isnull populates the values only doesnt replace


------------------------------------------
--breaking out address into individaul columns
select CHARINDEX(',', PropertyAddress,1)  from Sheet1   --------double quote gives error
select CHARINDEX(',', PropertyAddress,((select CHARINDEX(',', PropertyAddress,1))+1))  from Sheet1   --------double quote gives error,wihtout () near select gives errror and also after +1
select PropertyAddress from Sheet1

select CHARINDEX(' ', PropertyAddress,1)  from Sheet1
select SUBSTRING(PropertyAddress,1,((select CHARINDEX(' ', PropertyAddress,1) ))) from Sheet1    ----double repitition of sheet 1 giveing error
 

select SUBSTRING(PropertyAddress,1,((select CHARINDEX(',', PropertyAddress,1) -1) )) from Sheet1    -- -1 to exclude ,   

select SUBSTRING(PropertyAddress,1,((select CHARINDEX(' ', PropertyAddress,1) ))) from Sheet1 

alter table sheet1 add mainaddress nvarchar(255)
alter table sheet1 add mainaddresscity nvarchar(255)
update Sheet1 set mainaddress=
 SUBSTRING(PropertyAddress,1,((select CHARINDEX(',', PropertyAddress,1) -1) ))  ---donot use select word for substring as it has to be with "fromsheet 1" but sheet 1 is alredy mentioned in query
 update Sheet1 set  mainaddresscity=
 SUBSTRING(PropertyAddress,(select CHARINDEX(',', PropertyAddress,1) +1) ,LEN(propertyaddress)) 

 select * from sheet1

 --change Y N to yes no 
 select * from Sheet1 where SoldAsVacant='N'
  select * from Sheet1 where SoldAsVacant='Y'
 update Sheet1 set SoldAsVacant = 'No' where SoldAsVacant='N'
 update Sheet1 set SoldAsVacant = 'Yes' where SoldAsVacant='Y'
 select SoldAsVacant from Sheet1 group by SoldAsVacant



 -------------------
 --removing duplicates
 select * , ROW_NUMBER() over(
 partition by ParcelID,
 propertyaddress,
 saleprice,
 saledate,
 legalreference
 order by parcelid)row_num      --------same as wriring as rownum
 
 from Sheet1
 ----here rownum puts sequqential counting partiioing over avoe rows so after all those columns

 ---need for cte as rownum is a display fucnton only so creaing a view which is temporary table u an perform functions on  
 with rownumCTE()
 AS(                                                                  ------goes the query of which u want to get the temporary table of 
 
 select *,ROW_NUMBER() over(                ------rownum here tells the function which is to be performed over the partioning we are creating
 partition by ParcelID,
 propertyaddress,
 saleprice,
 saledate,
 legalreference
 order by uniqueid)
 as row_num 
 
 from Sheet1
 
 )
 





 ---delete unused column
 select * from Sheet1
 alter table sheet1 drop column
 owneraddress,propertyaddress



