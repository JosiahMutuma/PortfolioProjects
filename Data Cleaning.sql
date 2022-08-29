Select * 
From PortfolioProject.dbo.NashvilleHousing
Select SaleDate, CONVERT(Date, SaleDate) 
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate) 

-- Adding SaleDateConverted
ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

-- Populating the Property Address
Select PropertyAddress 
From PortfolioProject.dbo.NashvilleHousing 
Where PropertyAddress is null

Select * 
From PortfolioProject.dbo.NashvilleHousing 
-- Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfoioProject.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID] 
where a.PropertyAddress is null

-- Removing NULL Values
Update a SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfoioProject.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID] 
where a.PropertyAddress is null

-- SEPARATING VALUES IN PROPERTYINDEX FROM POSITION 1 TO COMMA'S POSITION
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address

-- SEPARATING VALUES IN PROPERTYINDEX FROM COMMA'S POSITION TO THE STRING'S FINAL POSITION
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
From PortfolioProject.dbo.NashvilleHousing

-- ADDING NEW COLUMNS TO FILL IN THE NEW DATA
ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- SEPARATING DATA
Select 
PARSENAME(REPLACE, OwnerAddress, ',', '.', 3)
PARSENAME(REPLACE, OwnerAddress, ',', '.', 2)
PARSENAME(REPLACE, OwnerAddress, ',', '.', 1)

-- ADDING THE DATA TO NEW COLUMNS
ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE, OwnerAddress, ',', '.', 3)

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE, OwnerAddress, ',', '.', 2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE, OwnerAddress, ',', '.', 1)

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From PortfolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant 
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes' 
	   When SoldAsVacant = '' THEN 'No' 
       ELSE SoldAsVacant 
       END
From PortfolioProject.dbo.NashvilleHousing 

-- ADDING THE DATA
Update NashvilleHousing 
SET SoldAsVacant, CASE When SoldAsVacant = 'Y' THEN 'Yes' 
	   When SoldAsVacant = '' THEN 'No' 
       ELSE SoldAsVacant 
       END
       
-- FINDING DUPLICATE VALUES
WITH RowNumCTE AS(
Select *, 
ROW_NUMBER() OVER( 
PARTITION BY ParcelID, 
			 PropertyAddress, 
             SalePrice, 
             SaleDate, 
             LegalReference 
             ORDER BY 
				UniqueID
                ) row_num 
From PortfolioProject.dbo.NashvilleHousing 
order by ParcelID
)

Select* 
From RowNumCTE 
Where row_num > 1 
order by PropertyAddress

-- REMOVING DUPLICATES
DELETE
From RowNumCTE 
Where row_num > 1 
order by PropertyAddress

-- DELETING UNUSED COLOMNS TO CLEAN UP THE DATA
ALTER TABLE PortfolioProject 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate