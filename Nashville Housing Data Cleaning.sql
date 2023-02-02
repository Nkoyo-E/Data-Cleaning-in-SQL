
--Retrieving all the data
SELECT *
FROM dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing

-- Populate Property Address Data

SELECT *
FROM dbo.NashvilleHousing
--Where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Breaking Out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcellD

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) 
							

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) 



SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE (PropertyAddress, ',', '.'), 3)
,PARSENAME(REPLACE (PropertyAddress, ',', '.'), 2)
,PARSENAME(REPLACE (PropertyAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (PropertyAddress, ',', '.'), 3)
							

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);


UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (PropertyAddress, ',', '.'), 2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (PropertyAddress, ',', '.'), 1)


--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) row_num

FROM dbo.NashvilleHousing
--Order By ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
Order By PropertyAddress


--Delete Unused Columns

FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

