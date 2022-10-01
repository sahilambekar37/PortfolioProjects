/*

Cleaning Data in SQL Queries

*/

--Some queries won't be running as columns named as PropertyAddress, SaleDate, OwnerAddress are dropped down at the last.



select *
from PortfolioProject..NashvilleHousing

-- standardize sale date format

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)




-- Populate Property Address Data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress = null
order by ParcelID


--

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]





-- Breaking Out Address Into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress = null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , len(PropertyAddress)) as Address

from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress varchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table NashvilleHousing
add PropertySplitCity varchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , len(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing


--another method instead of substring

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',' , '.') , 3)
,PARSENAME(replace(OwnerAddress, ',' , '.') , 2)
,PARSENAME(replace(OwnerAddress, ',' , '.') , 1)
from PortfolioProject..NashvilleHousing



alter table NashvilleHousing
add OwnerSplitAddress varchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',' , '.') , 3)


alter table NashvilleHousing
add OwnerSplitCity varchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',' , '.') , 2)



alter table NashvilleHousing
add OwnerSplitState varchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',' , '.') , 1)


select *
from PortfolioProject..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--After the above update check the select distinct count query



--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			order by
				UniqueID
				) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


--delete
with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			order by
				UniqueID
				) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--after this check the query before delete one


--delete unused columns


select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate