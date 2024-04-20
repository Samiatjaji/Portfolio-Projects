--CLEANING DATA FOR SQL QUERIES

select *
from PortfolioProject..NashvilleHousing  


-- STANDARDIZE DATE FORMATS
select SaleDate, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing --not effective enough
SET SaleDate = CONVERT(date,SaleDate) 

ALTER TABLE PortfolioProject..NashvilleHousing
add SaleDateConverted date

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate) 
--(so now we can say)
select SaleDateConverted, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing

--POPULATE PROPERTY ADDRESS DATE
select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--(now we try to populate the null addresses based on the fact that some parcel id exists twice)
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull ( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null
	
	--(then we update)
update a
set PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(Address, city, state)
select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN (PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN (PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

-- SEPERATING OWNER ADDRESS WITHOUT USING SUBSTRINGS
select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(replace(owneraddress,',','.') , 1),
PARSENAME(replace(owneraddress,',','.') , 2),
PARSENAME(replace(owneraddress,',','.') , 3 )

from PortfolioProject..NashvilleHousing
--(now we change the order)
select 
PARSENAME(replace(owneraddress,',','.') , 3),
PARSENAME(replace(owneraddress,',','.') , 2),
PARSENAME(replace(owneraddress,',','.') , 1)

from PortfolioProject..NashvilleHousing

--(then we add the values into three tables)
ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.') , 3)

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(owneraddress,',','.') , 2)

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(owneraddress,',','.') , 1)

--CHANGE Y AND N TO Yes and No in "sold as vacant" field

select distinct(SoldAsVacant), count (soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant, 
(	case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant  = 'N' then 'No'
	else soldasvacant
	end)
from PortfolioProject..NashvilleHousing

--(then lets update it)
update PortfolioProject..NashvilleHousing
set SoldAsVacant = (	case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant  = 'N' then 'No'
	else soldasvacant
	end)
from PortfolioProject..NashvilleHousing

--REMOVE DUPLICATES 

select *,
	ROW_NUMBER() over (
	partition by parcelID,
					propertyaddress,
					saleprice, 
					saledate, 
					legalreference
					order by 
						uniqueID) row_num
from PortfolioProject..NashvilleHousing
order by ParcelID 
--(we discovered a duplicate at 30069/30070, so now we proceed to cte to remove it)

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
					propertyaddress,
					saleprice, 
					saledate, 
					legalreference
					order by 
						uniqueID) row_num

from PortfolioProject..NashvilleHousing )
--order by ParcelID 
SELECT *
from RowNumCTE
Where row_num > 1
order by PropertyAddress

--(104 duplicates confirmed, now we delete)
with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
					propertyaddress,
					saleprice, 
					saledate, 
					legalreference
					order by 
						uniqueID) row_num

from PortfolioProject..NashvilleHousing )
--order by ParcelID 
DELETE
from RowNumCTE
Where row_num > 1
--order by PropertyAddress

--DELETE UNUSED COLUMNS

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column owneraddress, TaxDistrict, PropertyAddress
alter table PortfolioProject..NashvilleHousing
drop column saledate