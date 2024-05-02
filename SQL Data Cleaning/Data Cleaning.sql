-- Viewing all stuff

SELECT * 
FROM NashvilleHousing

--Correcting Date

SELECT SaleDate, CONVERT(date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE nashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM NashvilleHousing

-- Populate Property Address date

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- BREAK ADDRESS INTO INDIVIDUAL COLUMN ( ADDRESS, CITY, STATE)


--Property Address
SELECT PropertyAddress
FROM NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE nashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


--Owner Address
SELECT OwnerAddress
FROM NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE nashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



-- Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant)
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

UPDATE NashvilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'


UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

-- Remove Duplicates

SELECT *
FROM NashvilleHousing

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueId) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- deleting them

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueId) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
