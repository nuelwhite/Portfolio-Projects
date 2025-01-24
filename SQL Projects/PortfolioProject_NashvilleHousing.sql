/**
	* Cleaning data in sql
**/
select top 20 *
from NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- standardize the date format

select SaleDate
from NashvilleHousing -- this is in DateTime format and we have to take the time off

select SaleDate, convert(date, saledate)
from NashvilleHousing

-- update SaleDate format
alter table NashvilleHousing
add SaleDateConverted Date


update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------- 
-- Populate property address data
select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
	join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- update the null values
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
	join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from NashvilleHousing
order by ParcelID

-- charindex() returns position of the parameter
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address-- the -1 gets rid of the , and seperates by the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyaddress)) as Address 
from NashvilleHousing


-- create 2 new columns and add the seperated address

-- 1st table with Property split address
alter table nashvillehousing
add [Property Split Address] nvarchar(255)

update NashvilleHousing
set [Property Split Address] = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
from NashvilleHousing

-- 2nd column with city
alter table nashvillehousing
add [Property Address City] nvarchar(255)

update NashvilleHousing
set [Property Address City] = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyaddress)) 
from NashvilleHousing


--select top 20 * 
--from NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------
/**
	The previous spliting I used the substring method, this time I will use the parsename method to split the owners address which has equivalent values as the PropertyAddress

	* PARSENAME looks for '.' delimiters when seperating, but we can replace the period with a comma by using the replace method
	
	* the PARSENAME performs its function backwards (right-to-left) rather than the left-to-right
**/

select OwnerAddress
from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as ParsedState
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as ParsedCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as ParsedAddress
from NashvilleHousing

-- add new columns and update them with the splitted names

-- 1st column ParsedState
alter table nashvillehousing
add ParsedState nvarchar(255)

update NashvilleHousing
set ParsedState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--select ParsedState
--from NashvilleHousing

-- 2nd column ParsedCity
alter table nashvillehousing
add ParsedCity nvarchar(255)

update NashvilleHousing
set ParsedCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- 3rd column ParsedAddress
alter table nashvillehousing
add ParsedAddress nvarchar(255)

update NashvilleHousing
set ParsedAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select parsedState, parsedcity, parsedaddress
from NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------------
-- Change Y/N to Yes and No in "Sold as Vacant" field

-- first look at the sold as vacant column
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


-- using the CASE statement to update

select SoldAsVacant
, CASE
	when soldasvacant = 'y' then 'Yes'
	when soldasvacant = 'n' then 'No'
	else soldasvacant
	end
from NashvilleHousing


-- update the soldasvacant
update NashvilleHousing
set SoldAsVacant = CASE
	when soldasvacant = 'y' then 'Yes'
	when soldasvacant = 'n' then 'No'
	else soldasvacant
	end





-------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
-- using CTE because I don't actually want to remove the duplicate value
WITH RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
				 uniqueid
				 )row_num
from NashvilleHousing
)
--delete
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress


-------------------------------------------------------------------------------------------------------------------------------
-- Delete unused columns