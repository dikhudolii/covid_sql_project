SELECT *
FROM nashville_housing;

-- converting date column to YYYY-MM-DD
SELECT "SaleDate", TO_DATE("SaleDate", 'Month DD, YYYY') AS "ConvertedSaleDate"
FROM nashville_housing;

-- updating table
UPDATE nashville_housing
SET "SaleDate" = TO_DATE("SaleDate", 'Month DD, YYYY');

-- verifying that the SaleDate does not exist anymore and converted column exists
SELECT *
FROM nashville_housing;


------------------------------------------------------------------------------------------------------------------------

-- populate property address data
SELECT "PropertyAddress"
FROM nashville_housing;

-- some values are null, let's explore them
SELECT *
FROM nashville_housing
WHERE "PropertyAddress" IS NULL;

-- parcel id always matches with property address, so I can replace null values
SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress", COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM nashville_housing a
JOIN nashville_housing b ON a."ParcelID" = b."ParcelID"
    AND a."UniqueID " <> b."UniqueID "
WHERE a."PropertyAddress" IS NULL;

UPDATE nashville_housing
SET "PropertyAddress" = COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM nashville_housing a
JOIN nashville_housing b ON a."ParcelID" = b."ParcelID"
    AND a."UniqueID " <> b."UniqueID "
 WHERE a."PropertyAddress" IS NULL;


------------------------------------------------------------------------------------------------------------------------

-- breaking out address into individual columns (Address, City)
SELECT "PropertyAddress"
FROM nashville_housing;

SELECT
  trim(split_part("PropertyAddress", ',', 1)) AS Address,
  trim(split_part("PropertyAddress", ',', 2)) AS City
FROM nashville_housing;

-- Add new columns to the table
ALTER TABLE nashville_housing
ADD COLUMN property_address VARCHAR,
ADD COLUMN property_city VARCHAR;

-- Update the table to populate new columns
UPDATE nashville_housing
SET
  property_address = trim(split_part("PropertyAddress", ',', 1)),
  property_city = trim(split_part("PropertyAddress", ',', 2));

-- review the new columns
SELECT *
FROM nashville_housing;

-- breaking out owner address into address, city and state
SELECT
  trim(split_part("OwnerAddress", ',', 1)) AS Address,
  trim(split_part("OwnerAddress", ',', 2)) AS City,
  trim(split_part("OwnerAddress", ',', 3)) AS State
FROM nashville_housing;

-- add new columns
ALTER TABLE nashville_housing
ADD COLUMN owner_address VARCHAR,
ADD COLUMN owner_city VARCHAR,
ADD COLUMN owner_state VARCHAR;

-- Update the table to populate new columns
UPDATE nashville_housing
SET
  owner_address = trim(split_part("OwnerAddress", ',', 1)),
  owner_city = trim(split_part("OwnerAddress", ',', 2)),
  owner_state = trim(split_part("OwnerAddress", ',', 3));

-- review new columns
SELECT property_city, property_address, owner_address, owner_city, owner_state
FROM nashville_housing;


------------------------------------------------------------------------------------------------------------------------

-- Change Y/N to Yes/No in "Sold as Vacant" field
SELECT DISTINCT "SoldAsVacant", count("SoldAsVacant")
FROM nashville_housing
GROUP BY "SoldAsVacant"
ORDER BY 2;

SELECT "SoldAsVacant",
       case when "SoldAsVacant" = 'Y'then 'Yes'
           when "SoldAsVacant" = 'N' then 'No'
            ELSE "SoldAsVacant"
            END
FROM nashville_housing;

-- Update the table to populate new values
UPDATE nashville_housing
SET "SoldAsVacant" = case when "SoldAsVacant" = 'Y'then 'Yes'
           when "SoldAsVacant" = 'N' then 'No'
            ELSE "SoldAsVacant"
            END


------------------------------------------------------------------------------------------------------------------------

-- remove duplicates
WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY "ParcelID",
                   "PropertyAddress",
                   "SalePrice",
                   "SaleDate",
                   "LegalReference"
      ORDER BY "UniqueID "
    ) AS row_num
  FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE ("ParcelID", "PropertyAddress", "SalePrice", "SaleDate", "LegalReference") IN (
  SELECT "ParcelID", "PropertyAddress", "SalePrice", "SaleDate", "LegalReference"
  FROM RowNumCTE
  WHERE row_num > 1
);


------------------------------------------------------------------------------------------------------------------------

-- delete unused columns

SELECT *
FROM nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN owner_address,
DROP COLUMN "TaxDistrict",
DROP COLUMN "PropertyAddress";
























