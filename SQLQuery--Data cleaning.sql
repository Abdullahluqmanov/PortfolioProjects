/*

Cleaning data in SQL queries

*/

SELECT * 
FROM PortfolioProject.dbo.NashvilHousing;

------------------------------------------------------------------------------------------
-- Standardize the date format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.NashvilHousing;


ALTER TABLE PortfolioProject.dbo.NashvilHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilHousing
SET SaleDateConverted = CONVERT(date,SaleDate);

SELECT * 
FROM PortfolioProject.dbo.NashvilHousing;


------------------------------------------------------------------------------------------

--Populate property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilHousing
--WHERE PropertyAddress IS NULL;
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilHousing a
JOIN PortfolioProject.dbo.NashvilHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilHousing a
JOIN PortfolioProject.dbo.NashvilHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

------------------------------------------------------------------------------------------
---Breaking out Address into individual columns ( Address, City, State)

--Part One: Breaking out the PropertyAddress


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City

FROM PortfolioProject.dbo.NashvilHousing

ALTER TABLE PortfolioProject.dbo.NashvilHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE PortfolioProject.dbo.NashvilHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT * 
FROM PortfolioProject.dbo.NashvilHousing;


--Part two: Breaking out the OwnerAddress: 

SELECT OwnerAddress 
FROM PortfolioProject.dbo.NashvilHousing; 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),   -- The reason to change ',' to '.' is that the PARSENAME will only work with '.'
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)    -- We should use '3/2/1' cuz normally the PARSENAME works from backwords. 
FROM PortfolioProject.dbo.NashvilHousing;        -- As we can see this is an easy way to extract different data

--Now I'm going to update the table and add the new value into it.

ALTER TABLE PortfolioProject.dbo.NashvilHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilHousing
SET OwnerSplitAddress = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilHousing
ADD OwnerSplitCity Nvarchar(255);


UPDATE PortfolioProject.dbo.NashvilHousing
SET OwnerSplitCity = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilHousing
SET OwnerSplitState = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM PortfolioProject.dbo.NashvilHousing


------------------------------------------------------------------------------------------
---Change Y and N to Yes and No in 'Sold as vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant                -- The ELSE statement here means: If the value is neither Y nor N, it will keep the original value. In this case it's the 'No' / 'Yes'
	END
FROM PortfolioProject.dbo.NashvilHousing

UPDATE PortfolioProject.dbo.NashvilHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant               
	END
FROM PortfolioProject.dbo.NashvilHousing

SELECT SoldAsVacant
FROM PortfolioProject.dbo.NashvilHousing;



------------------------------------------------------------------------------------------
--- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() over(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
	UniqueID
	)row_num

FROM PortfolioProject.dbo.NashvilHousing
)

SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

------------------------------------------------------------------------------------------
--Delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilHousing;

ALTER TABLE PortfolioProject.dbo.NashvilHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE PortfolioProject.dbo.NashvilHousing
DROP COLUMN SaleDate;


-- Recap summary: 


