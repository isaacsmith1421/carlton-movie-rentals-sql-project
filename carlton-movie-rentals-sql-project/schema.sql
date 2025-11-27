-- DROP ALL TABLES FOR CARLTON MOVIE RENTALS --

USE carlton_movie_rentals;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS RentalItem;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Rental;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS MovieGenre;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Store;
DROP TABLE IF EXISTS MembershipPlan;

SET FOREIGN_KEY_CHECKS = 1;

USE carlton_movie_rentals;

CREATE TABLE MembershipPlan (
    MembershipID INT AUTO_INCREMENT PRIMARY KEY,
    PlanName VARCHAR(50) NOT NULL,
    MonthlyFee DECIMAL(6,2) NOT NULL,
    MaxActiveRentals INT NOT NULL,
    LateFeeDiscountPercent INT DEFAULT 0,
    CreatedDate DATE NOT NULL,
    IsActive TINYINT(1) DEFAULT 1
);

CREATE TABLE Store (
    StoreID INT AUTO_INCREMENT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    AddressLine1 VARCHAR(150),
    Suburb VARCHAR(100),
    Postcode VARCHAR(10),
    State VARCHAR(10),
    OpenedDate DATE,
    IsOpen TINYINT(1) DEFAULT 1
);

CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    DateOfBirth DATE,
    SignupDate DATE NOT NULL,
    MembershipID INT,
    IsActive TINYINT(1) DEFAULT 1,
    PreferredStoreID INT,
    FOREIGN KEY (MembershipID) REFERENCES MembershipPlan(MembershipID),
    FOREIGN KEY (PreferredStoreID) REFERENCES Store(StoreID)
);

CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(150),
    Role VARCHAR(50),
    StoreID INT NOT NULL,
    HireDate DATE,
    IsActive TINYINT(1) DEFAULT 1,
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
);


CREATE TABLE Movie (
    MovieID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    ReleaseYear INT,
    Rating VARCHAR(10),
    RuntimeMinutes INT,
    Language VARCHAR(50),
    RentalPrice DECIMAL(6,2),
    ReplacementCost DECIMAL(6,2),
    IsActive TINYINT(1) DEFAULT 1
);

CREATE TABLE Genre (
    GenreID INT AUTO_INCREMENT PRIMARY KEY,
    GenreName VARCHAR(50) NOT NULL
);

CREATE TABLE MovieGenre (
    MovieID INT NOT NULL,
    GenreID INT NOT NULL,
    PRIMARY KEY (MovieID, GenreID),
    FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
);

CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    MovieID INT NOT NULL,
    StoreID INT NOT NULL,
    DateAdded DATE,
    Status VARCHAR(20),
    CopyNumber INT,
    FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
);

CREATE TABLE Rental (
    RentalID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    StaffID INT NOT NULL,
    StoreID INT NOT NULL,
    RentalDateTime DATETIME NOT NULL,
    ReturnDueDate DATETIME,
    TotalAmount DECIMAL(8,2),
    PaymentStatus VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
);

CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    RentalID INT NOT NULL,
    PaymentDateTime DATETIME NOT NULL,
    Amount DECIMAL(8,2),
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (RentalID) REFERENCES Rental(RentalID)
);

CREATE TABLE RentalItem (
    RentalItemID INT AUTO_INCREMENT PRIMARY KEY,
    RentalID INT NOT NULL,
    InventoryID INT NOT NULL,
    DailyRate DECIMAL(6,2),
    ReturnDateTime DATETIME,
    LateFeeAmount DECIMAL(8,2),
    FOREIGN KEY (RentalID) REFERENCES Rental(RentalID),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);










