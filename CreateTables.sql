--ALTER TABLE Models DROP CONSTRAINT FK_Model_ProducerId
--ALTER TABLE Producers DROP CONSTRAINT PK__Producer__1336965269160541
--DROP TABLE Producers

CREATE TABLE Producers(
    ProducerId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(255) NOT NULL,
	Country NVARCHAR(255) NOT NULL
);

CREATE TABLE Models(
    ModelId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL,
    ProducerId INT
);

CREATE TABLE Equipments(
    EquipmentId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ModelId INT NOT NULL,
	EngineId INT NOT NULL,
    Transmission NVARCHAR(255) NOT NULL,
	Body NVARCHAR(255) NOT NULL,
	FuelConsumption FLOAT NOT NULL,
	Additional NVARCHAR(255),
	Price INT NOT NULL
);

CREATE TABLE Engines(
    EngineId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(255) NOT NULL,
	FuelType NVARCHAR(255) NOT NULL,
	[Power] INT NOT NULL,
	[Type] NVARCHAR(255) NOT NULL
);

CREATE TABLE Cars(
    CarId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	EquipmentId INT NOT NULL,
	BodyNumber INT,
	[State] NVARCHAR(255) NOT NULL,
	Color NVARCHAR(255) NOT NULL,
	Kilometrage INT,
	Cost INT NOT NULL,
	Guarantee INT NOT NULL
);

CREATE TABLE Sales(
    SaleId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	CarId INT NOT NULL,
	ClientId INT NOT NULL,
	SalesDate DATETIME2
);

CREATE TABLE EmployeeCompensations(
    CompensationId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	SaleId INT NOT NULL,
	EmployeeId INT NOT NULL,
	[Value] INT NOT NULL
);

CREATE TABLE Employees(
    EmployeeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Position NVARCHAR(255) NOT NULL,
	[Name] NVARCHAR(255) NOT NULL,
	Phone INT NOT NULL,
	Salary INT NOT NULL
);

CREATE TABLE Clients(
    ClientId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(255) NOT NULL,
	Phone INT NOT NULL,
	Country NVARCHAR(255),
	City NVARCHAR(255)
);

CREATE TABLE CustomerOrders(
    CustomerOrderId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	ClientId INT NOT NULL,
	CarId INT NOT NULL,
	Amount INT NOT NULL,
	[State] NVARCHAR(255),
	OrderDate DATETIME2 
);

CREATE TABLE CarFromTheClient(
    CarFromTheClientId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	ClientId INT NOT NULL,
	CarId INT NOT NULL,
	PurchasePrice INT NOT NULL,
	[Date] DATETIME2 
);

CREATE TABLE GuaranteeCases(
    GuaranteeCaseId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	ClientId INT NOT NULL,
	CarId INT NOT NULL,
	[Date] DATETIME2,
	[Status] NVARCHAR(255) NOT NULL,
	[Description] NVARCHAR(255) NOT NULL
);   

ALTER TABLE Models
   ADD CONSTRAINT FK_Model_ProducerId FOREIGN KEY (ProducerId)
      REFERENCES Producers(ProducerId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE Equipments
   ADD CONSTRAINT FK_Equipment_ModelId FOREIGN KEY (ModelId)
      REFERENCES Models(ModelId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE Equipments
   ADD CONSTRAINT FK_Equipment_EngineId FOREIGN KEY (EngineId)
      REFERENCES Engines(EngineId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE Cars
   ADD CONSTRAINT FK_Cars_EquipmentId FOREIGN KEY (EquipmentId)
      REFERENCES Equipments(EquipmentId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE Sales
   ADD CONSTRAINT FK_Sales_CarId FOREIGN KEY (CarId)
      REFERENCES Cars(CarId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE Sales
   ADD CONSTRAINT FK_Sales_ClientId FOREIGN KEY (ClientId)
      REFERENCES Clients(ClientId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE EmployeeCompensations
   ADD CONSTRAINT FK_EmployeeCompensations_SaleId FOREIGN KEY (SaleId)
      REFERENCES Sales(SaleId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE EmployeeCompensations 
   ADD CONSTRAINT FK_EmployeeCompensations_EmployeeId FOREIGN KEY (EmployeeId)
      REFERENCES Employees(EmployeeId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE CarFromTheClient
   ADD CONSTRAINT FK_CarFromTheClient_ClientId FOREIGN KEY (ClientId)
      REFERENCES Clients(ClientId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE CarFromTheClient
   ADD CONSTRAINT FK_CarFromTheClient_CarId FOREIGN KEY (CarId)
      REFERENCES Cars(CarId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE GuaranteeCases
   ADD CONSTRAINT FK_GuaranteeCases_CarId FOREIGN KEY (CarId)
      REFERENCES Cars(CarId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE GuaranteeCases
   ADD CONSTRAINT FK_GuaranteeCases_ClientId FOREIGN KEY (ClientId)
      REFERENCES Clients(ClientId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE CustomerOrders
   ADD CONSTRAINT FK_CustomerOrders_ClientId FOREIGN KEY (ClientId)
      REFERENCES Clients(ClientId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE CustomerOrders
   ADD CONSTRAINT FK_CustomerOrders_CarId FOREIGN KEY (CarId)
      REFERENCES Cars(CarId)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;