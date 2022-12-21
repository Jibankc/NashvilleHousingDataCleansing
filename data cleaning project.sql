--Cleaning Data in SQL queries
Select *
from dbo.NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------------------------
--Standarize Date format
Select SaleDateConverted, Convert(Date, SaleDate)
from dbo.NashvilleHousing

Update NashvilleHousing 
SET saledate = CONVERT(Date, Saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
SET saledateConverted = CONVERT(Date, Saledate)

---------------------------------------------------------------

--Populate Property Address data

select * from dbo.NashvilleHousing 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET Propertyaddress = ISNULL(a.propertyAddress, b.PropertyAddress) 
from dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------
--Breaking out address into Individual columns(address, city , state)
select propertyaddress 
from dbo.NashvilleHousing 
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(propertyaddress, 1, CHARINDEX (',', propertyaddress)-1) as Address,
SUBSTRING(propertyaddress,  CHARINDEX (',', propertyaddress)+1, LEN(propertyAddress))as Address
from dbo.NashvilleHousing 

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX (',', propertyaddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity =SUBSTRING(propertyaddress,  CHARINDEX (',', propertyaddress)+1, LEN(propertyAddress))

---------------------------------------------------------------------------------


Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from dbo.Nashvillehousing 

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
   SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

   
Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
   SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

----------------------------------------------------------------------------------
--Change Y and N to Yes and No in "SOld as vacant" field

Select Distinct(soldasvacant), Count(soldasvacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select soldasvacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
from dbo.NashvilleHousing

Update NashvilleHousing 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
from dbo.NashvilleHousing

---------------------------------------------------------------------------------------------
---Remove duplicate
WITH RowNumCTE AS(
select *,
ROW_NUMBER()OVER(Partition BY ParcelID, 
							PropertyAddress, 
							SalePrice, 
							SaleDate, 
							LegalReference
							Order BY
								UniqueID) row_num
from dbo.NashvilleHousing 
)
--Delete
select* 
from RowNUMCTE
where row_num > 1

Select * from dbo.NashvilleHousing

ALTER Table dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table dbo.nashvillehousing
DROP COLUMN saledate

