/*  
Data cleaning in SLQ queries LAWRENCE THE ANALYST 
*/
Select  *
from [PortfolioProject ].dbo.[NashvilleHousing ]

/* 1. Standard Date Format 
we are trying to change the date format from this (2016-03-28 00:00:00.000) to this (2016-03-28)
step one we convert using "cast(value, as date)" or "convert(date,value)"
*/

Select  saleDate, cast(saledate as date)
from [PortfolioProject ].dbo.[NashvilleHousing ]

---------- OR

Select  saleDate, convert(date,saledate) as NewSalesDate
from [PortfolioProject ].dbo.[NashvilleHousing ]

---- This code didnt change the date format in the data base
update [NashvilleHousing ]
set saleDate =convert(date,saleDate)  

---- prove that it did not happen below 
Select  saledate
from [PortfolioProject ].dbo.[NashvilleHousing ]

---- i will try doing it another way
-- so by doing this i am altering the table by adding a new column "saledateconverted"

Alter table Nashvillehousing 
add SaleDateConverted date;

--i will update this into the database using the "update" function

update [NashvilleHousing ]
set SaleDateConverted =convert(date,saleDate)

-- prove that it worked 
Select  saledateconverted 
from [PortfolioProject ].dbo.[NashvilleHousing ]


---2. Populate Property Address Data
-- we are trying to remove null values from propert address 

Select  propertyaddress
from [PortfolioProject ].dbo.[NashvilleHousing ]

--- to check if i have null values at the property address column

Select  propertyaddress
from [PortfolioProject ].dbo.[NashvilleHousing ]
where propertyaddress is null

---- select all the place where property address is null in the database 

select *
from [PortfolioProject ].dbo.[NashvilleHousing ]
where Propertyaddress is null 

--lets look at parcelID her we discovered that we have duplicate parcelId and the duplicate has the same address 
select *
from [PortfolioProject ].dbo.[NashvilleHousing ]
--where Propertyaddress is null 
order by parcelid 

-- join the table to itself 

select *
from [PortfolioProject ].dbo.[NashvilleHousing ] a
join [PortfolioProject ].dbo.[NashvilleHousing ] b
     on a.ParcelID = b.ParcelID
	AND  a.UniqueID <> b.UniqueID

---- select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress 

select  a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress 
from [PortfolioProject ].dbo.[NashvilleHousing ] a
join [PortfolioProject ].dbo.[NashvilleHousing ] b
     on a.ParcelID = b.ParcelID
	AND  a.UniqueID <> b.UniqueID

	---- where property address is null
	select  a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress 
from  [PortfolioProject ].dbo.[NashvilleHousing ] a
join [PortfolioProject ].dbo.[NashvilleHousing ] b
     on a.ParcelID = b.ParcelID
	AND  a.UniqueID <> b.UniqueID
where a.propertyaddress is null

--- i introduced the ISNULL function so where we have null values i input a value using this function
---- ISNULL(a.propertyaddress,b.propertyaddress)
select  a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress) 
from [PortfolioProject ].dbo.[NashvilleHousing ] a
join [PortfolioProject ].dbo.[NashvilleHousing ] b
     on a.ParcelID = b.ParcelID
	AND  a.UniqueID <> b.UniqueID
where a.propertyaddress is null

----we update our data base
--N:B when updating a join we need to add the alias a and not nashvillehousing 

update a
set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress) 
from [PortfolioProject ].dbo.[NashvilleHousing ] a
join [PortfolioProject ].dbo.[NashvilleHousing ] b
     on a.ParcelID = b.ParcelID
	AND  a.UniqueID <> b.UniqueID
	where a.propertyaddress is null

---- then we check .... too see the query will display any null values in property address and parcelid

select  a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress) 
from [PortfolioProject ].dbo.[NashvilleHousing ] a
join  [PortfolioProject ].dbo.[NashvilleHousing ] b
     on a.ParcelID = b.ParcelID
	AND  a.UniqueID <> b.UniqueID
where a.propertyaddress is null

select  *
from [PortfolioProject ].dbo.[NashvilleHousing ]



-- 3. Breaking out Address (5548  MURPHYWOOD XING, ANTIOCH) into individual columns (address, city) 

select propertyaddress
from [PortfolioProject ].dbo.[NashvilleHousing ]

 -- we separate thepropertyaddress to look nicer using substring so we remove the "city" first
 
 select  
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)) as Address

from [PortfolioProject ].dbo.[NashvilleHousing ]

---- we use CHARINDEX(',', propertyaddress) to show the position by number (20.19,22 etc) of the ","
	 select  
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)) as Address,
CHARINDEX(',', propertyaddress)
from [PortfolioProject ].dbo.[NashvilleHousing ]

----So i want to get rid of the comma so i apply "-1" to eliminate the ","
--So the address can be displayed without showing the comma 

select  
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as Address

from [PortfolioProject ].dbo.[NashvilleHousing ]

-- I removed the address and display the city

select  
 SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress)) as AddressCity
from [PortfolioProject ].dbo.[NashvilleHousing ] 
 
 ---or show both address and city
select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
,
 SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress)) as City
from [PortfolioProject ].dbo.[NashvilleHousing ]

-- add a new table 
select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
,
 SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress)) as City
from [PortfolioProject ].dbo.[NashvilleHousing ]

Alter table Nashvillehousing 
add propertysplitAddress nvarchar(255);


update [NashvilleHousing ]
set propertysplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)-1)

Alter table Nashvillehousing 
add propertysplitCity nvarchar(255);

update [NashvilleHousing ]
set propertysplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress))



---4.Breaking out Address () into individual columns (address, city, state) from the owneraddress column

select OwnerAddress
from [PortfolioProject ].dbo.[NashvilleHousing ]

--PARSENAME ONLY works with period"." and in this case we have a comma 
--we have to convert the comma to period in order to use PARSENAME

select 
PARSENAME(replace(owneraddress, ',', '.'),3),
PARSENAME(replace(owneraddress, ',', '.'),2),
PARSENAME(replace(owneraddress, ',', '.'),1)
from [PortfolioProject ]..[NashvilleHousing ]

---we update the address 


Alter table Nashvillehousing 
add OwnersplitAddress nvarchar(255);

update [NashvilleHousing ]
set OwnersplitAddress = PARSENAME(replace(owneraddress, ',', '.'),3)

Alter table Nashvillehousing 
add OwnersplitCity nvarchar(255);

update [NashvilleHousing ]
set OwnersplitCity = PARSENAME(replace(owneraddress, ',', '.'),2)

Alter table Nashvillehousing 
add OwnersplitState nvarchar(255);

update [NashvilleHousing ]
set OwnersplitState = PARSENAME(replace(owneraddress, ',', '.'),1)

-- 5. change Y and N to Yes and No in Sold as "Vacant field" or column
--- this code will display all the "Yes, NO, Y, and N" in the database 

select (SoldAsVacant)
from [PortfolioProject ].dbo.[NashvilleHousing ]

---- when i add the Distinct funtion this will be displayed differently

select Distinct(SoldAsVacant)
from [PortfolioProject ].dbo.[NashvilleHousing ]

---show the number yes and no by count 

select Distinct(SoldAsVacant), count(soldasvacant)
from [PortfolioProject ].dbo.[NashvilleHousing ]
group by SoldAsVacant
order by 2

--- here i apply a CASE statement

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END 
from [PortfolioProject ].dbo.[NashvilleHousing ]

-- we update the database 

update [NashvilleHousing ]
set SoldAsVacant =  CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END 


---Delect columns
--- is not the best practice to alter data in your database


Alter table portfolioproject..nashvillehousing 
drop column saledate, ownerssplitaddress, owneraddress, propertyaddress

--Thanks 


 




