--CLEANING DATA IN SQL 

---------------------------------------------------------------------------------------------------------------------

--Standardize Date format
Select SaleDate1
From Portfolio_project..NashvilleHousing

Update Portfolio_project..NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

--Didnt work properly so used another way
Alter Table Portfolio_project..NashvilleHousing
Add SaleDate1 Date;

Update Portfolio_project..NashvilleHousing
Set SaleDate1 = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------

--Populate Property Address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_project..NashvilleHousing as a
Join Portfolio_project..NashvilleHousing as b
     On a.ParcelID = b.ParcelID
     And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_project..NashvilleHousing as a
Join Portfolio_project..NashvilleHousing as b
     On a.ParcelID = b.ParcelID
     And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

---------------------------------------------------------------------------------------------------------------------

--Breaking out Address into different individual columns (Address, City, State)
Select PropertyAddress, PARSENAME(REPLACE(PropertyAddress,',','.'),2),
                        PARSENAME(REPLACE(PropertyAddress,',','.'),1)
From Portfolio_project..NashvilleHousing 

Alter Table Portfolio_project..NashvilleHousing
Add PropertyAddress1 Nvarchar(255);

Update Portfolio_project..NashvilleHousing
Set PropertyAddress1 = PARSENAME(REPLACE(PropertyAddress,',','.'),2)

Alter Table Portfolio_project..NashvilleHousing
Add City Nvarchar(255);

Update Portfolio_project..NashvilleHousing
Set City = PARSENAME(REPLACE(PropertyAddress,',','.'),1)


Select OwnerAddress,PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
                    PARSENAME(REPLACE(OwnerAddress,',','.'),2),
                    PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Portfolio_project..NashvilleHousing 


Alter Table Portfolio_project..NashvilleHousing
Add OwnerAddress1 Nvarchar(255);

Update Portfolio_project..NashvilleHousing
Set OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table Portfolio_project..NashvilleHousing
Add OwnerCity Nvarchar(255);

Update Portfolio_project..NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table Portfolio_project..NashvilleHousing
Add OwnerState Nvarchar(255);

Update Portfolio_project..NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field

Select SoldAsVacant, COUNT(SoldAsVacant)
From Portfolio_project..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant ,
       Case 
	       When SoldAsVacant = 'Y' Then 'Yes'
           When SoldAsVacant = 'N' Then 'No'
	       Else SoldAsVacant
	   End
From Portfolio_project..NashvilleHousing

Update Portfolio_project..NashvilleHousing
Set  SoldAsVacant = Case 
	                    When SoldAsVacant = 'Y' Then 'Yes'
                        When SoldAsVacant = 'N' Then 'No'
					    Else SoldAsVacant
					End

---------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH CTE_duplicates as
(
Select * , ROW_NUMBER() over(partition by ParcelID,
                                          PropertyAddress1,
										  SaleDate1,
										  SalePrice,
										  LegalReference,
										  OwnerAddress1
                                          order by UniqueID) as row_num
From Portfolio_project..NashvilleHousing
)
Delete
From CTE_duplicates
Where row_num > 1

---------------------------------------------------------------------------------------------------------------------

--Deleting unused columns

Alter Table Portfolio_project..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select * 
From Portfolio_project..NashvilleHousing