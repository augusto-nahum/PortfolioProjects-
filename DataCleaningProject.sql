-- Cleaning data in SQL queries

select *
from PortfolioProject..NashvilleHousing

-- Standarize date format

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = convert (date, SaleDate)

select SaleDateConverted, convert (date, SaleDate)
from PortfolioProject..NashvilleHousing

-- Populate Property Address data
select *
from PortfolioProject..NashvilleHousing
order by ParcelID

---- lo que hice:
--#uni la tabla con si misma para compararla
--#las uni por si tiene el mismo ParcleID pero diferente UniqueID
--#si en un PropertyAddress es null lo lleno con el valor que se repite

-- (Al final elimino PropertyAddress, por lo que si ejecuto este codigo me da error)

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

--Breaking out address into individual columns (Address, city, state) : Property

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, charindex( ',', PropertyAddress) - 1 ) as Address ,-- el -1 para que no aparezaca la coma, el charindex da la posicion de la coma
SUBSTRING(PropertyAddress, charindex( ',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255) ;

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex( ',', PropertyAddress) - 1 )

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, charindex( ',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing


-- Otra forma de hacerlo : Owners

select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'), 3) ,
PARSENAME(replace(OwnerAddress,',','.'), 2) ,
PARSENAME(replace(OwnerAddress,',','.'), 1)  
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255) ;

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar (255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)

select *
from PortfolioProject..NashvilleHousing

--Change Y and N to Yes and NO in 'Sold as vacant' field

select distinct(SoldAsVacant) -- para saber cuales son los distintos valores que aparecen en la columna
from PortfolioProject..NashvilleHousing

Select SoldAsVacant,
	Case 
	when SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
set SoldAsVacant =  
Case 
	when SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END


-- Remove Duplicates

with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID) row_num

from PortfolioProject..NashvilleHousing
)

select *
from RowNumCTE
where row_num > 1 
order by PropertyAddress

delete
from RowNumCTE
where row_num > 1 


-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacantCorregido

Alter table PortfolioProject..NashvilleHousing
drop column SaleDate
