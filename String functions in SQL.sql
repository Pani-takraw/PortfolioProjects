-- Creating a new table for practice
CREATE TABLE EmployeeErrors (
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)

-- Inserting the data with errors for practice
Insert into EmployeeErrors Values 
('1001  ', 'Jimbo', 'Halbert')
,('  1002', 'Pamela', 'Beasely')
,('1005', 'TOby', 'Flenderson - Fired')


-- Querying data
Select * from EmployeeErrors

-- Using TRIM, LTRIM, RTRIM
-- Trim will remove the extra spaces on both left and right of the string
Select EmployeeID, TRIM(EmployeeID) as IDTrim FROM EmployeeErrors

-- LTRIM will remove spaces on the left/starting of the string
-- RTRIM will remove spaces on the right/end of the string
Select EmployeeID, LTRIM(EmployeeID) as IDTrim FROM EmployeeErrors

Select EmployeeID, RTRIM(EmployeeID) as IDTrim FROM EmployeeErrors

-- Using Replace function to replace a part of the string
Select LastName, REPLACE(LastName, '- fired', '') as Lastnamefixed From EmployeeErrors

-- Using Substring to extract the needed length of a string
-- Here we are extracting the first three letters in the FirstName column
Select FirstName, SUBSTRING(FirstName, 1,3) From EmployeeErrors


-- UPPER and Lower will change the text into Uppercase or lowercase

Select FirstName,LOWER(FirstName), LastName, UPPER(LastName) From EmployeeErrors



