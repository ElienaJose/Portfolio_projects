SELECT *
FROM portfolio_project.dbo.NashvilleHousing

SELECT COUNT(1)
FROM portfolio_project.dbo.NashvilleHousing

--Standardize date format

--SELECT SaleDate
--FROM portfolio_project.dbo.NashvilleHousing

--UPDATE portfolio_project.dbo.NashvilleHousing
--SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

--Populate property Address

SELECT COUNT(*)
FROM portfolio_project.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM portfolio_project.dbo.NashvilleHousing
ORDER BY 2

--We see that for those records where the parcel id's are same, their addresses are also same. So we populate with this logic in mind.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) AS PropertyAddressCorrected
FROM portfolio_project.dbo.NashvilleHousing a
JOIN portfolio_project.dbo.NashvilleHousing b
ON a.[UniqueID ] <> b.[UniqueID ] AND a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL

--ALTER TABLE NashvilleHousing
--ADD PropertyAddressCorrected VARCHAR(255);

--ALTER TABLE NashvilleHousing
--DROP COLUMN PropertyAddressCorrected

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_project.dbo.NashvilleHousing a
JOIN portfolio_project.dbo.NashvilleHousing b
ON a.[UniqueID ] <> b.[UniqueID ] AND a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL

--Breaking out address into individual columns

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) AS City
FROM portfolio_project.dbo.NashvilleHousing


ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE portfolio_project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE portfolio_project.dbo.NashvilleHousing
SET PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) 

--Breaking out Owneraddress into address, state and city

SELECT COUNT(*)
FROM portfolio_project.dbo.NashvilleHousing
WHERE OwnerAddress IS NULL


SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM portfolio_project.dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE portfolio_project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE portfolio_project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE portfolio_project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--CHANGE 'Y' and 'N' TO 'YES' and 'NO' in SoldasVacant Field 

SELECT SoldAsVacant ,COUNT(1) AS Total_counts
FROM portfolio_project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                           WHEN SoldAsVacant = 'N' THEN 'No'
						   ELSE SoldAsVacant
						   END AS SoldAsVacantCorrected
						  
FROM portfolio_project.dbo.NashvilleHousing


UPDATE portfolio_project.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                           WHEN SoldAsVacant = 'N' THEN 'No'
						   ELSE SoldAsVacant
						   END 

-- Remove duplicates

With row_no_cte
AS 
(SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY ParcelID) AS Row_no
FROM portfolio_project.dbo.NashvilleHousing)

DELETE FROM row_no_cte
WHERE Row_no > 1

--The duplicates are removed from the cte table.

--Remove unused columns

ALTER TABLE portfolio_project.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,SaleDate
