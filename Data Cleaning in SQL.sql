/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * FROM [PortfolioProjects].[dbo].[NashvilleHousing]

-- Standardize date format by removing time zone

Select SaleDate, CONVERT(Date, SaleDate) From PortfolioProjects..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)



ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted From PortfolioProjects..NashvilleHousing

-- Populationg Property address because we have some null values with reference point ParcelId
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out address into individual columns by splitting address and cities
Select PropertyAddress from NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS city
From PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(250);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(250);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Heare we are going to split the owner address into address, city and state
SELECT OwnerAddress FROM PortfolioProjects..NashvilleHousing

-- PARSNAME Will look for dot so we have used REPLACE function from backwards so when we run 1,2,3 it will give State, city and address
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) ,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
FROM PortfolioProjects..NashvilleHousing

-- To split the address properly we can reverse the numbers as 3,2,1
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) ,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM PortfolioProjects..NashvilleHousing


-- Updating the adddress format to the original table

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(250);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(250);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitState NVARCHAR(250);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Changing Y and N to Yes and NO

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant

-- We can achieve this by using a CASE statement
Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'n' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProjects..NashvilleHousing


Update PortfolioProjects..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'n' THEN 'No'
	 ELSE SoldAsVacant
	 END

