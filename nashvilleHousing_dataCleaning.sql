
-- *DATA CLEANING WITH SQL*
SELECT * FROM nashville_housing 


-- Change date to normal format 
SELECT SaleDate, CONVERT(Date, SaleDate) AS converted_sale_date
FROM nashville_housing

UPDATE nashville_housing
SET SaleDate = CONVERT(Date, SaleDate)

--or 
ALTER TABLE nashville_housing
ADD converted_sale_date Date;

UPDATE nashville_housing
SET converted_sale_date = CONVERT(Date, SaleDate)


-- Populate Property Address  
SELECT * 
FROM nashville_housing 
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress 
FROM nashville_housing x 
JOIN nashville_housing y     
    ON x.ParcelID = y.ParcelID AND x.UniqueID <> y.UniqueID
WHERE PropertyAddress IS NULL

UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM nashville_housing x 
JOIN nashville_housing y     
    ON x.ParcelID = y.ParcelID AND x.UniqueID <> y.UniqueID
WHERE PropertyAddress IS NULL


--Seperating address column into address, city and state columns 
SELECT * 
FROM nashville_housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS city
FROM nashville_housing

ALTER TABLE nashville_housing
ADD property_address NVARCHAR(255);

UPDATE nashville_housing 
SET property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE nashville_housing
ADD property_city NVARCHAR(255);

UPDATE nashville_housing 
SET property_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM nashville_housing

-- Splitting OwnerAddress 
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM nashville_housing


ALTER TABLE nashville_housing
ADD owner_address NVARCHAR(255);
UPDATE nashville_housing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE nashville_housing
ADD owner_city NVARCHAR(255);
UPDATE nashville_housing 
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE nashville_housing
ADD owner_state NVARCHAR(255);
UPDATE nashville_housing 
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 



-- Change Y to Yes and N to No in SoldAsVacant column 
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) AS Total 
FROM nashville_housing 
GROUP BY SoldAsVacant 
ORDER BY 2

SELECT 
SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = 
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END

-- Remove Duplicates
WITH row_num_CTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    ORDER BY UniqueID 
    ) row_num
FROM nashville_housing
)
DELETE
FROM row_num_CTE
WHERE row_num > 1


-- Delete Unused Columns
SELECT * 
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
