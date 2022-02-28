-- Creating a table "EmployeeDetails"
DROP Table if exist EmployeeDetails           -- This command will drop the table "EmployeeDetails" if it already exists in the DB
Create Table EmployeeDetails (
EmployeeID int,
FirstName Varchar(100),
LastName Varchar(100),
Age int
)

-- Inserting Data into "EmployeeDetails"
Insert Into EmployeeDetails Values 
(1001, 'Pani', 'Vignesh', 27),
(1002, 'Elango', 'Padmanaban', 25),
(1003, 'Yukesh', 'Nagarajan', 25),
(1004, 'Vignesh','Ramesh', 28)

-- Querying Table EmployeeDetails which we have just created

Select * From EmployeeDetails

Select EmployeeID, FirstName From EmployeeDetails

Select FirstName, LastName, Age From EmployeeDetails
