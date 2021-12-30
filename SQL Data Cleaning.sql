


SELECT *
FROM Portfolio..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT saleDateConverted, 
       CONVERT(DATE,SaleDate)
FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Portfolio..NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE Portfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM Portfolio..NashvilleHousing
	--WHERE PropertyAddress IS NULL
	ORDER BY ParcelID

SELECT a.ParcelID, 
       a.PropertyAddress, 
       b.ParcelID, 
       b.PropertyAddress, 
       ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
	--WHERE PropertyAddress IS NULL
	--ORDER BY ParcelID

SELECT	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) Address
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Portfolio..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM Portfolio..NashvilleHousing

SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM Portfolio..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), 
       COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

SELECT SoldAsVacant, 
(CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END)
FROM Portfolio..NashvilleHousing

UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant = (CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END)

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num
FROM Portfolio..NashvilleHousing
	--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
	ORDER BY PropertyAddress

SELECT *
FROM Portfolio..NashvilleHousing
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, 
            TaxDistrict, 
	    PropertyAddress, 
	    SaleDate


