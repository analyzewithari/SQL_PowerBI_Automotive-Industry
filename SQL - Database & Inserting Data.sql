/*DATABASE CREATION AND DATA INSERTION*/

CREATE DATABASE Automotive_Industry;

/*Sentiment*/
CREATE TABLE Sentiment (
	Postal_Code INT PRIMARY KEY,	
	Date DATE,	
	Sentiment VARCHAR(50) NOT NULL,
	Year INT
);
-- ----------------------------------------------------------------------------------------------------

/*Dealers*/
CREATE TABLE Dealers (
	Dealer_ID INT PRIMARY KEY,
	Country VARCHAR(255) NOT NULL,
	State VARCHAR(255) NOT NULL,
	City VARCHAR(255) NOT NULL,
	Zip_Code VARCHAR(255) NOT NULL,
	Address VARCHAR(255) NOT NULL,
	Dealer_Name VARCHAR(255) NOT NULL,
	Contact_Name VARCHAR(255) NOT NULL,
	Phone_Number VARCHAR(255) NOT NULL,
	Latitude INT,
	Longitude INT
);
-- ----------------------------------------------------------------------------------------------------

/*Models*/
CREATE TABLE Models (
	Car_ID INT PRIMARY KEY,
	Model VARCHAR(255) NOT NULL,
);
-- ----------------------------------------------------------------------------------------------------

/*Recalls*/
CREATE TABLE Recalls (
	Date DATE,
	Car_ID INT,
	System_Affected VARCHAR(255),
	Units INT,
	FOREIGN KEY (Car_ID)
        REFERENCES Models (Car_ID)
);
-- ----------------------------------------------------------------------------------------------------

/*Sale_Model*/
CREATE TABLE Sale_Model (
	Date DATE,
	Model_ID INT,
	Dealer_ID INT,
	Quantity_Sold INT,
	Profit INT,
	FOREIGN KEY (Model_ID)
        REFERENCES Models (Car_ID),
	FOREIGN KEY (Dealer_ID)
        REFERENCES Dealers (Dealer_ID),
);
-- ----------------------------------------------------------------------------------------------------

/*Sale_Daily*/
CREATE TABLE Sale_Daily (
	Sales_ID INT,
	Count INT,
	Open_Date DATE,
	Year INT,
	Month_Order INT,
	DaysMake_Sale INT,
	Car_ID INT,
	Dealer_ID INT,
	Temperature FLOAT,
	Temperature_Category VARCHAR(255),
	WeatherCondition VARCHAR(255),
	Humidity FLOAT,
	WindSpeed FLOAT,
	WindGust FLOAT,
	WindDirection VARCHAR(225),
	Visibility FLOAT,
	WindChill FLOAT,
	Precipitation FLOAT,
	Fog VARCHAR(50),
	Rain VARCHAR(50),
	Snow VARCHAR(50),
	FOREIGN KEY (Car_ID)
        REFERENCES Models (Car_ID),
	FOREIGN KEY (Dealer_ID)
        REFERENCES Dealers (Dealer_ID),
);
-- ----------------------------------------------------------------------------------------------------
/*Inserting Data into Automotive_Industry database*/
