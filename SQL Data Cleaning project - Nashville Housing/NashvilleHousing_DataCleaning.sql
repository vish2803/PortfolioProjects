/* 
Cleaning data in SQL 
*/

SELECT * FROM NashvilleHousing


-- Standardize Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate) FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted FROM NashvilleHousing

-----------------------------------------------------------------------------------------------------------

-- Populate Property Address Data (We will fill in all NULL values in PropertyAddress by checking if those values are available for same ParcelID)

SELECT ParcelID, PropertyAddress FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--So now we see no NULL values in PropertyAddress

-----------------------------------------------------------------------------------------------------------

-- Separate Address , City , State into different columns

--Firstly we will do using SUBSTRING and CHARINDEX functions for PropertyAddress column

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1) AS PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS PropertySplitCity
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT * FROM NashvilleHousing


-- Secondly we will do using PARSENAME function for OwnerAddress column

SELECT
PARSENAME ( REPLACE(OwnerAddress,',','.'), 3) ,
PARSENAME ( REPLACE(OwnerAddress,',','.'), 2),
PARSENAME ( REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME ( REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME ( REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD PropertySplitState nvarchar(255)

UPDATE PARSENAME ( REPLACE(OwnerAddress,',','.'), 2)
SET PropertySplitState = PARSENAME ( REPLACE(OwnerAddress,',','.'), 1)


----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant column

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT SoldAsVacant FROM NashvilleHousing
-- Only shows Yes and No now

--------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
ORDER BY UniqueID
) row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM ROWNUMCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- So we deleted all the columns with row_num > 1 which indicated they were duplicates. 
--(first we checked by putting SELECT instead of DELETE to see the duplicate rows and then deleted)

-----------------------------------------------------------------------------------------------------------------

-- Delete unused columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict