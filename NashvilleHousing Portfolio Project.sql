--Cleaning Data in SQL Queries

Select *
From PortfolioProject..NashvilleHousing



--Standadized Sale Date Format

Select SaledateConverted, Convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)



--Populate Property Address data

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, IsNull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress --This can also be in a string in form of say No Address)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Breaking out Property Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) /*to remove the comma*/ As Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) /*to go 
forward by one which is to avoid the comma*/ As Address
From PortfolioProject..NashvilleHousing

--Execute Alter first before Update for each one
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) /*to remove the comma*/

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) /*to go 
forward by one which is to avoid the comma*/


Select *
From PortfolioProject..NashvilleHousing



--Using another method (simpler) to Break out Owner Address into Individual Columns (Address, City, State)
Select 
ParseName(Replace(OwnerAddress, ',', '.'), 3) As Street--I am trying to Parse comma but since parse only recorgnises full stop, i replaced the comma with full stop then parsed it
, ParseName(Replace(OwnerAddress, ',', '.'), 2) As City
, ParseName(Replace(OwnerAddress, ',', '.'), 1) As State
From PortfolioProject..NashvilleHousing

--Execute Alter first before Update for each one
Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject..NashvilleHousing


--CHange Y and N to Yes and NO in 'Sold as Vacant' Field
--distinct ensures that the result set contains only distinct (unique) values and removes any duplicate rows.
Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant --used because of the count function
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant 
		End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant 
		End


--Remove Duplicate eg rank, row

With RowNumCTE As(
Select *,
	Row_number() Over (
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
						UniqueID
						) Row_num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Select * --Select in other to see it first
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


--To now remove it
With RowNumCTE As(
Select *,
	Row_number() Over (
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
						UniqueID
						) Row_num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1



--Deleting Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALter Table PortfolioProject..NashvilleHousing
Drop COlumn OwnerAddress, TaxDistrict, PropertyAddress
--I couldn't add this to the Alter above because i already carry out the command, i have rewite its own so i don't run the above command twice if i add it to the above
ALter Table PortfolioProject..NashvilleHousing
Drop COlumn SaleDate