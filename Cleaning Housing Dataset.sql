select *
from Project.. Housing 
----------Converting date format---
----Firstly we alter the table by adding a newcoloumn name----
alter table Housing
add saledateconverted date;
---then we set the new column name to the old column whilst converted----then update the table----------
update Housing
set saledateconverted= convert(date, saledate)
------------Showing the updated table-----------------------------------------
select saledateconverted, convert(date, saledate)
from Project.. Housing
------------------Cleaning the property address data----------------
select a.parcelID, b.parcelID, a.propertyaddress, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from Project.. Housing a
join Project.. Housing b
on a.parcelID=b.parcelID
and a.uniqueID<>b.uniqueID
where a.propertyaddress is null

update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from Project.. Housing a
join Project.. Housing b
on a.parcelID=b.parcelID
and a.uniqueID<>b.uniqueID
where a.propertyaddress is null
--------Separating the addresss------------
select 
substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as Address,
substring (propertyaddress,charindex(',', propertyaddress)+1, len(propertyaddress)) as AddressName
from Housing
-----We need to create new columns to add the splitted addresses--------
alter table housing 
add propertysplittedaddress nvarchar(255)
update housing
set propertysplittedaddress=substring(propertyaddress, 1, charindex(',', propertyaddress)-1)

alter table housing 
add propertysplittedcity nvarchar(255)
update housing
set propertysplittedcity =substring (propertyaddress,charindex(',', propertyaddress)+1, len(propertyaddress)) 

-------Cleaning owners to more usable form-----------
select owneraddress
from Housing
select 
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from Housing

alter table housing 
add Ownersplittedaddress nvarchar(255)

update housing
set Ownersplittedaddress=parsename(replace(owneraddress,',','.'),3)

alter table housing 
add OwnersplittedCity nvarchar(255)

update housing
set OwnersplittedCity=parsename(replace(owneraddress,',','.'),2)

alter table housing 
add OwnersplittedState nvarchar(255)

update housing
set OwnersplittedState=parsename(replace(owneraddress,',','.'),1)
-----------changing Y<N to Yes or No in sold as vacant column
select distinct (soldasvacant), count(soldasvacant)
from Housing
group by soldasvacant
order by 2

select soldasvacant,
case
when soldasvacant='y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end
from project..Housing
----------Updating the table-----------
update Housing
set soldasvacant=case
when soldasvacant='y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end
----------Removing dublicates using CTEs--------
with rownumCTE as (
select*,
row_number() over(
partition by
parcelID,
propertyAddress,
SalePrice,
SaleDate,
LegalReference
order by uniqueID) row_num
from Project.. Housing
)
select*
from rownumCTE
where row_num>1
order by Propertyaddress
Delete
from rownumCTE
where row_num>1
--order by Propertyaddress
 -----Deleting unused columns  -------------

 select*
 from Project.. Housing 

 alter table housing
 drop column
 OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
