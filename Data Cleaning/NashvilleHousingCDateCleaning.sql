/*

# Cleaning Data in MySql Queries

*/

USE Nashville_Housing;


SELECT * FROM nashville_housingC;


-- Standardize Data Format --

SELECT SaleDate, DATE(SaleDate) AS SaleDates
FROM nashville_housingC;

ALTER TABLE nashville_housingC
	MODIFY COLUMN SaleDate DATE NOT NULL;
    

-- Populate Property Address Data --

SELECT * FROM nashville_housingC
WHERE PropertyAddress is null
ORDER BY ParcelID;


# Use Join to find out those PropertyAddress are NULL under same ParcelID but different UniqueID 
SELECT 
	a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housingC a
JOIN nashville_housingC b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL; 


-- Update column: 'PropertyAddress' of null value and replace with correct address --

UPDATE nashville_housingC a
JOIN nashville_housingC b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



-- --------------------------------------------------------------------

-- Breaking out Address into Individual Columns(Address, City, State) --
-- Split Property Address --

SELECT PropertyAddress
FROM  nashville_housingC;
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID


SELECT 
	SUBSTRING_INDEX(PropertyAddress, ",", 1) AS PropertySplitAddress,
	SUBSTRING_INDEX(PropertyAddress, ",", -1) AS PropertySplitCity
FROM  nashville_housingC;


ALTER TABLE nashville_housingC
	ADD COLUMN PropertySplitAddress VARCHAR(250),
    ADD COLUMN PropertySplitCity VARCHAR(250);


UPDATE nashville_housingC
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ",", 1),
	PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ",", -1);


SELECT * FROM nashville_housingC;


-- Split OwnerAddress into address, city and state --

SELECT OwnerAddress FROM nashville_housingC;


SELECT OwnerAddress,
	SUBSTRING_INDEX(OwnerAddress, ",", 1) AS OwnerSplitAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 2), "," , -1) AS OwnerSplitCity,
    SUBSTRING_INDEX(OwnerAddress, ",", -1) AS OwnerSplitState
FROM nashville_housingC;


ALTER TABLE nashville_housingC
	ADD COLUMN OwnerSplitAddress VARCHAR(250),
    ADD COLUMN OwnerSplitCity VARCHAR(250),
    ADD COLUMN OwnerSplitState VARCHAR(50);


UPDATE nashville_housingC
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ",", 1),
	OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 2), "," , -1),
    OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ",", -1);


SELECT * FROM nashville_housingC;


-- --------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAs Vacant" field --

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS countN		
FROM nashville_housingC
GROUP BY SoldAsVacant
ORDER BY countN;

SELECT 
	SoldAsVacant,
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END
FROM nashville_housingC;

UPDATE nashville_housingC
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END;



-- --------------------------------------------------------------------

# Remove Duplications

WITH dups AS (
	SELECT 
		*,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
					 PropertyAddress, 
                     SalePrice, 
                     SaleDate, 
                     LegalReference
		ORDER BY UniqueID) row_num

	FROM nashville_housingC
)

DELETE n
FROM dups
JOIN nashville_housingC n USING (UniqueID)
WHERE row_num > 1;


-- --------------------------------------------------------------------

# Delete Unused Columns

SELECT * FROM nashville_housingC;

ALTER TABLE nashville_housingC
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress, 
DROP COLUMN TaxDistrict;


