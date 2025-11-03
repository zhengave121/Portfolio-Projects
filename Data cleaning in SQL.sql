-- Cleaning data in SQL queries --
-- Cleaning the data to make it more usable --

Select *
From PortfolioProject.dbo.NashvilleHousing


--- Standardize SaleDate format
Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--- Populate property address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- ISNULL checks to see if a.PropertyAddress is null if it is null it will populate with b.PropertyAddress
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--- Breaking out address into individual columns (address, city, state)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select
--Looking at PropertyAddress starting at the first value, then going until the ,
--CHARINDEX output is 19 saying that the , is at position 19 / use -1 to remove ,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
--Add +1 to remove , at the beginning
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--Added 2 new columns PropertySplitAddress and PropertySplitCity to the dataset at the end
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Select *
--From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--PARSENAME only checks for .
--REPLACE , with .
Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

--Added 3 new columns OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState to the dataset at the end
Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--Select *
--From PortfolioProject.dbo.NashvilleHousing


-- Checking for Yes, No, Y, and N
Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


--- Change Y and N to Yes and No in 'SoldAsVacant' field
Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
END


--- Remove duplicates
WITH RowNumCTE AS(
Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by 
UniqueID
) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1 
order by PropertyAddress


--- Delete unused columns
--Select *
--From PortfolioProject.dbo.NashvilleHousing

--Removes the 4 columns listed
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

