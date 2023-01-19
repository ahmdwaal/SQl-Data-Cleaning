/*
Cleaning Data in SQL Queries
*/


Select *
From housing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
alter table housing
alter column SaleDate type date USING saledate::date

select saledate
from housing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From housing
Where PropertyAddress is null
order by ParcelID

Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
From housing a
JOIN housing b
	on a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
Where a.propertyaddress is null

Update housing
SET propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)
From housing a
JOIN housing b
	on a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
Where a.propertyaddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

alter table housing
add column propertysplitaddress varchar(50)

update housing
set propertysplitaddress = substring(propertyaddress,1,position(',' in propertyaddress)-1)

alter table housing
add column propertysplitcity varchar(50)

update housing
set propertysplitcity = substring(propertyaddress, position(',' in propertyaddress)+1,length(propertyaddress))

select split_part(owneraddress,',',1),
	split_part(owneraddress,',',2),
	split_part(owneraddress,',',3)
from housing
where owneraddress is not null

alter table housing
add column ownersplitaddress varchar(50)

update housing
set ownersplitaddress = split_part(owneraddress,',',1)

alter table housing
add column ownersplitcity varchar(50)

update housing
set ownersplitcity = split_part(owneraddress,',',2)

alter table housing
add column ownersplitstate varchar(50)

update housing
set ownersplitstate = split_part(owneraddress,',',3)

select *
from housing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(soldasvacant), Count(soldasvacant)
From housing
Group by soldasvacant
order by 2

Select soldasvacant
, CASE When soldasvacant = 'Y' THEN 'Yes'
	   When soldasvacant = 'N' THEN 'No'
	   ELSE soldasvacant
	   END
From housing

UPDATE housing
SET soldasvacant = CASE When soldasvacant = 'Y' THEN 'Yes'
	   					When SoldAsVacant = 'N' THEN 'No'
	  					ELSE SoldAsVacant
	   			   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Check for Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueiD
					) row_num

From housing
)
Select *
From RowNumCTE
Where row_num > 1
Order by propertyaddress




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



ALTER TABLE housing
DROP COLUMN IF EXISTS owneraddress,
DROP COLUMN IF EXISTS taxdistrict,
DROP COLUMN IF EXISTS propertyaddress;



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------