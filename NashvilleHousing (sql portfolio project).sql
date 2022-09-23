Select * from [portfolio project]..NashvilleHousing

--convert date format of SaleDate
select SaleDateConverted, Convert(date, SaleDate)             --step3
from [portfolio project]..NashvilleHousing

update NashvilleHousing
set SaleDate=Convert(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date                                    --step1

update NashvilleHousing
set SaleDateConverted=Convert(date, SaleDate)                 --step2

--populate property address data

select * from [portfolio project]..NashvilleHousing 
where PropertyAddress is null 


select * from [portfolio project]..NashvilleHousing 
order by ParcelID                                             --property address with same parcel are same

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyAddress, b.PropertyAddress)
from [portfolio project]..NashvilleHousing a
join [portfolio project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

update a
set PropertyAddress = isnull(a.propertyAddress, b.PropertyAddress)
from [portfolio project]..NashvilleHousing a
join [portfolio project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--breaking out address into three individul columns (Address, city, state)

select PropertyAddress from [portfolio project]..NashvilleHousing 

Select
PARSENAME(replace(PropertyAddress, ',','.'),2)                   --parse doesnt read ',' so replace with '.' 
,PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)               --easy method to split a column
From [portfolio project]..NashvilleHousing

ALTER TABLE [portfolio project]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)      

update [portfolio project]..NashvilleHousing
set PropertySplitAddress=PARSENAME(replace(propertyAddress, ',','.'),2)


ALTER TABLE [portfolio project]..NashvilleHousing
Add PropertySplitCity Nvarchar(255)  

update [portfolio project]..NashvilleHousing
set PropertySplitCity=PARSENAME(replace(propertyAddress, ',','.'),1)

Select OwnerAddress
From [portfolio project]..NashvilleHousing                      --another method to split a column

SELECT
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1 ) as Address
, SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1 , LEN(OwnerAddress)) as Address

From [portfolio project]..NashvilleHousing

ALTER TABLE [portfolio project]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)      

update [portfolio project]..NashvilleHousing
set OwnerSplitAddress=SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1 ) 


ALTER TABLE [portfolio project]..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)      

update [portfolio project]..NashvilleHousing
set OwnerSplitCity=SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1 , LEN(OwnerAddress))

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [portfolio project]..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
From [portfolio project]..NashvilleHousing

update [portfolio project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end

	 
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [portfolio project]..NashvilleHousing
)
select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



-- Delete Unused Columns

Select *
From [portfolio project]..NashvilleHousing


ALTER TABLE [portfolio project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

