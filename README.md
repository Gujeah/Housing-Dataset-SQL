<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<h1>Housing Data Processing README</h1>

<p>This README provides a step-by-step guide to processing the Housing dataset. The dataset is was stored in the <code>Project.. Housing</code> table.</p>

<h2>Converting Date Format</h2>

<p>I started by converting the date format in the dataset.</p>

<pre><code>
<!-- Adding a new column for converted sale date -->
alter table Housing
add saledateconverted date;

<!-- Updating the new column with converted date -->
update Housing
set saledateconverted = convert(date, saledate);

<!-- Displaying the updated table -->
select saledateconverted, convert(date, saledate) as original_saledate
from Project.. Housing;
</code></pre>

<h2>Cleaning Property Address Data</h2>

<p>Cleaning and separating the property address data.</p>

<pre><code>
<!-- Checking for and updating null property addresses -->
select a.parcelID, b.parcelID, a.propertyaddress, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from Project.. Housing a
join Project.. Housing b
on a.parcelID=b.parcelID
and a.uniqueID<>b.uniqueID
where a.propertyaddress is null;

<!-- Updating null property addresses -->
update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from Project.. Housing a
join Project.. Housing b
on a.parcelID=b.parcelID
and a.uniqueID<>b.uniqueID
where a.propertyaddress is null;

<!-- Separating the address into Address and AddressName -->
select 
substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as Address,
substring (propertyaddress,charindex(',', propertyaddress)+1, len(propertyaddress)) as AddressName
from Housing;

<!-- Creating new columns for splitted addresses -->
alter table housing 
add propertysplittedaddress nvarchar(255);

alter table housing 
add propertysplittedcity nvarchar(255);

<!-- Updating the new columns with splitted address data -->
update housing
set propertysplittedaddress=substring(propertyaddress, 1, charindex(',', propertyaddress)-1);

update housing
set propertysplittedcity =substring (propertyaddress,charindex(',', propertyaddress)+1, len(propertyaddress));
</code></pre>

<h2>Cleaning Owner Information</h2>

<p>Cleaning and splitting owner address information for better usability.</p>

<pre><code>
<!-- Splitting owner address into address, city, and state -->
alter table housing 
add Ownersplittedaddress nvarchar(255);

alter table housing 
add OwnersplittedCity nvarchar(255);

alter table housing 
add OwnersplittedState nvarchar(255);

<!-- Updating the new columns with splitted owner address data -->
update housing
set Ownersplittedaddress=parsename(replace(owneraddress,',','.'),3);

update housing
set OwnersplittedCity=parsename(replace(owneraddress,',','.'),2);

update housing
set OwnersplittedState=parsename(replace(owneraddress,',','.'),1);
</code></pre>

<h2>Updating Sold as Vacant Column</h2>

<p>Converting 'Y' and 'N' values in 'soldasvacant' column to 'Yes' and 'No'.</p>

<pre><code>
<!-- Updating 'soldasvacant' column values -->
update Housing
set soldasvacant = case
when soldasvacant='y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end;
</code></pre>

<h2>Removing Duplicates</h2>

<p>Removing duplicate entries from the dataset.</p>

<pre><code>
<!-- Removing duplicates using Common Table Expressions (CTEs) -->
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
delete
from rownumCTE
where row_num>1;
</code></pre>

<h2>Deleting Unused Columns</h2>

<p>Deleting unused columns from the dataset.</p>

<pre><code>
<!-- Deleting unused columns -->
alter table housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
</code></pre>

<h1>Conclusion: Knowledge Gained from Housing Data Processing</h1>

<p>Through the process of handling the Housing dataset and performing various SQL operations, several key skills and insights have been gained:</p>

<ol>
  <li><strong>Data Cleaning Techniques:</strong> The dataset required thorough cleaning, including handling null values, converting date formats, and separating address information. This process enhanced understanding of data cleaning techniques and their importance in preparing datasets for analysis.</li>
  
  <li><strong>SQL Query Execution:</strong> Execution of complex SQL queries such as joins, updates, and deletions was necessary to manipulate the dataset according to specific requirements. This process improved proficiency in writing and executing SQL queries effectively.</li>
  
  <li><strong>Data Transformation:</strong> The transformation of data, such as splitting address information and converting values in a column, showcased the ability to transform raw data into a more structured and usable format. Understanding how to manipulate data to meet analysis needs is a critical skill in data processing.</li>
  
  <li><strong>Duplicate Data Handling:</strong> Dealing with duplicate entries in the dataset required the use of Common Table Expressions (CTEs) and understanding of partitioning data for deletion. This experience provided insights into managing duplicate data effectively.</li>
  
  <li><strong>Understanding Data Structure:</strong> By examining the dataset's structure and identifying unused columns, an understanding of data organization and optimization was developed. Knowing which columns are necessary for analysis helps streamline data processing and analysis workflows.</li>
  
  <li><strong>Documentation Skills:</strong> Creating a comprehensive README document to explain each step of the data processing journey enhanced documentation and communication skills. Clear documentation is essential for sharing knowledge and collaborating effectively with team members.</li>
  
  <li><strong>Domain Knowledge:</strong> Engaging with housing data provided insights into the real estate domain, including common data challenges and the importance of accurate and structured data for housing analysis and decision-making.</li>
</ol>

<p>Overall, the process of handling the Housing dataset and performing various SQL operations contributed to the development of essential data processing skills, SQL proficiency, and domain knowledge, which can be applied to similar data processing tasks in the future.</p>
</body>
</html>
