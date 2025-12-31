/* Cleaning Data in SQL Queries */
select saledateconverted from nashhousing;

-- standarize Date Format

alter table nashhousing add column SaleDateConverter date;

update nashhousing set SaleDateConverter = convert(saledate, date);

select SaleDateConverter from nashhousing;


-- Populate Property Address data 
select * from nashhousing
-- where PropertyAddress is null
order by ParcelID;

select a.PropertyAddress, a.UniqueID, b.PropertyAddress, b.UniqueID from nashhousing as a join nashhousing as b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a set PropertyAddress = coalesce(a.PropertyAddress, b.PropertyAddress) 
from nashhousing as a join nashhousing as b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- Breaaking out Address Into Individual columns (Address, City, State)

select substring(PropertyAddress,1, locate(',', PropertyAddress) -1) as FirstAddress ,
substring(PropertyAddress, locate(',', PropertyAddress) +1 , length(PropertyAddress)) as LastAddress
from nashhousing;


alter table nashhousing add column PropertySplitAddress varchar(255);

update nashhousing set PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) -1);

alter table nashhousing add column PropertySplitCity varchar(255);

update nashhousing set PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) +1 , length(PropertyAddress));


select PropertySplitAddress , PropertySplitCity from nashhousing ;

-- change Y and N to yes and No in " sold as vacant" field
select distinct(soldasvacant), count(soldasvacant)
from nashhousing 
group by soldasvacant 
order by soldasvacant;

select soldasvacant , 
case 
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end 
from nashhousing ;

update nashhousing set soldasvacant = case 
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end ;

-- Remove Duplicate


with RowNumCTE as (
select * , 
row_number() over(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueID) as row_number
from nashhousing;
);

select * from RowNumCTE
where row_number > 1
order by PropertyAddress;

delete from RowNumCTE where row_number > 1;


-- delete unused columns
select * from nashhousing;
alter table nashhousing drop column ownerAddress , TaxDistrict, PropertyAddress, SaleDate ;







