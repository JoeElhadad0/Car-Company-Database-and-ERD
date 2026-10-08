IF DB_ID('CarCompanyDB') IS NULL
    CREATE DATABASE CarCompanyDB
GO

USE CarCompanyDB
GO

CREATE TABLE Vehicles (
    VehicleID INT PRIMARY KEY,
    VehicleName VARCHAR(50) NOT NULL
)

CREATE TABLE Manufacturers (
    ManufacturerID INT PRIMARY KEY,
    ManufacturerName VARCHAR(50) NOT NULL
)

CREATE TABLE Models (
    ModelID INT PRIMARY KEY,
    ModelName VARCHAR(50) NOT NULL,
    ProductionDate DATE,
    VehicleID INT NOT NULL,
    ManufacturerID INT NOT NULL,
    CONSTRAINT FK_Models_Vehicles FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    CONSTRAINT FK_Models_Manufacturers FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
)


CREATE TABLE Features (
    FeatureID INT PRIMARY KEY,
    FeatureName VARCHAR(50) NOT NULL
)


CREATE TABLE ModelFeatures (
    ModelID INT NOT NULL,
    FeatureID INT NOT NULL,
    CONSTRAINT PK_ModelFeatures PRIMARY KEY (ModelID, FeatureID),
    CONSTRAINT FK_ModelFeatures_Models FOREIGN KEY (ModelID) REFERENCES Models(ModelID),
    CONSTRAINT FK_ModelFeatures_Features FOREIGN KEY (FeatureID) REFERENCES Features(FeatureID)
)

CREATE TABLE CarsForSale (
    CarID INT PRIMARY KEY,
    Price DECIMAL(12,2) NOT NULL CHECK (Price > 0),
    IsSold BIT NOT NULL DEFAULT 0,
    ModelID INT NOT NULL,
    CONSTRAINT FK_CarsForSale_Models FOREIGN KEY (ModelID) REFERENCES Models(ModelID)
)

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    PhoneNum VARCHAR(20)
)

CREATE TABLE SoldCars (
    SaleID INT PRIMARY KEY,
    CarID INT NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    SaleDate DATE NOT NULL,
    SaleType VARCHAR(20) NOT NULL,
    RepaymentStart DATE,
    RepaymentEnd DATE,
    MonthlyPay DECIMAL(12,2),
    TotalPaid DECIMAL(12,2) NOT NULL DEFAULT 0,
    RemainingBalance DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_SoldCars_CarsForSale FOREIGN KEY (CarID) REFERENCES CarsForSale(CarID),
    CONSTRAINT FK_SoldCars_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT CK_SoldCars_SaleType CHECK (SaleType IN ('Cash', 'Installment')),

    CONSTRAINT CK_SoldCars_Plan CHECK (SaleType = 'Cash' OR (RepaymentStart IS NOT NULL AND RepaymentEnd IS NOT NULL AND MonthlyPay IS NOT NULL)),
    CONSTRAINT CK_SoldCars_Dates CHECK (RepaymentEnd IS NULL OR RepaymentStart IS NULL OR RepaymentEnd >= RepaymentStart)
)

CREATE TABLE CustomerPayments (
    PayID INT PRIMARY KEY,
    SaleID INT NOT NULL,
    PayDate DATE NOT NULL,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount > 0),
    CONSTRAINT FK_CustomerPayments_SoldCars FOREIGN KEY (SaleID) REFERENCES SoldCars(SaleID)
)
GO

INSERT INTO Vehicles (VehicleID, VehicleName) VALUES
(1, 'Sedan'),
(2, 'SUV')

INSERT INTO Manufacturers (ManufacturerID, ManufacturerName) VALUES
(1, 'Toyota'),
(2, 'BMW'),
(3, 'Hyundai')

INSERT INTO Models (ModelID, ModelName, ProductionDate, VehicleID, ManufacturerID) VALUES
(1, 'Camry',   '2024-03-01', 1, 1),
(2, 'Corolla', '2024-01-15', 1, 1),
(3, 'X5',      '2023-09-10', 2, 2),
(4, 'Tucson',  '2024-05-20', 2, 3)

INSERT INTO Features (FeatureID, FeatureName) VALUES
(1, 'Sunroof'),
(2, 'Leather Seats'),
(3, 'Navigation'),
(4, 'Backup Camera')

INSERT INTO ModelFeatures (ModelID, FeatureID) VALUES
(1, 1), (1, 2), (1, 4),
(2, 4),
(3, 1), (3, 2), (3, 3), (3, 4),
(4, 3), (4, 4)

INSERT INTO CarsForSale (CarID, Price, IsSold, ModelID) VALUES
(1, 1200000, 1, 1),
(2,  900000, 1, 2),
(3, 3500000, 0, 3),
(4, 1300000, 0, 4),
(5, 1350000, 0, 4)

INSERT INTO Customers (CustomerID, CustomerName, PhoneNum) VALUES
(1, 'Mohamed Hassan', '01011112222'),
(2, 'Nour Adel',      '01122223333'),
(3, 'Ali Samir',      '01233334444')

INSERT INTO SoldCars (SaleID, CarID, CustomerID, SaleDate, SaleType, RepaymentStart, RepaymentEnd, MonthlyPay, TotalPaid, RemainingBalance) VALUES
(1, 1, 1, '2026-08-01', 'Cash',        NULL,         NULL,         NULL,  1200000, 0),
(2, 2, 2, '2026-08-15', 'Installment', '2026-09-15', '2027-08-15', 50000, 350000,  550000)

INSERT INTO CustomerPayments (PayID, SaleID, PayDate, Amount) VALUES
(1, 1, '2026-08-01', 1200000),
(2, 2, '2026-08-15',  300000),
(3, 2, '2026-09-15',   50000)
GO

SELECT
    Models.ModelName,
    Vehicles.VehicleName AS VehicleType,
    Manufacturers.ManufacturerName
FROM Models
INNER JOIN Vehicles ON Models.VehicleID = Vehicles.VehicleID
INNER JOIN Manufacturers ON Models.ManufacturerID = Manufacturers.ManufacturerID

SELECT
    Models.ModelName,
    Features.FeatureName
FROM Models
LEFT JOIN ModelFeatures ON Models.ModelID = ModelFeatures.ModelID
LEFT JOIN Features ON ModelFeatures.FeatureID = Features.FeatureID
ORDER BY Models.ModelName

SELECT
    CarsForSale.CarID,
    Manufacturers.ManufacturerName,
    Models.ModelName,
    CarsForSale.Price
FROM CarsForSale
INNER JOIN Models ON CarsForSale.ModelID = Models.ModelID
INNER JOIN Manufacturers ON Models.ManufacturerID = Manufacturers.ManufacturerID
WHERE CarsForSale.IsSold = 0
ORDER BY CarsForSale.Price

SELECT
    SoldCars.SaleID,
    Customers.CustomerName,
    Models.ModelName,
    SoldCars.SaleType,
    SoldCars.TotalPaid,
    SoldCars.RemainingBalance
FROM SoldCars
INNER JOIN Customers ON SoldCars.CustomerID = Customers.CustomerID
INNER JOIN CarsForSale ON SoldCars.CarID = CarsForSale.CarID
INNER JOIN Models ON CarsForSale.ModelID = Models.ModelID

SELECT
    SoldCars.SaleID,
    SoldCars.TotalPaid AS StoredTotal,
    SUM(CustomerPayments.Amount) AS PaymentsTotal
FROM SoldCars
LEFT JOIN CustomerPayments ON SoldCars.SaleID = CustomerPayments.SaleID
GROUP BY SoldCars.SaleID, SoldCars.TotalPaid

SELECT Customers.CustomerName
FROM Customers
LEFT JOIN SoldCars ON Customers.CustomerID = SoldCars.CustomerID
WHERE SoldCars.SaleID IS NULL
