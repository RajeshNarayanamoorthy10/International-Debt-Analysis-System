-- =====================================================
-- Project      : International Debt Analysis System
-- Phase        : SQL Table Creation
-- Author       : Rajesh
-- Description  : TO create the required Database and tables
-- =====================================================



CREATE database international_debt_db;

use international_debt_db;

CREATE TABLE countries (
	country_code varchar(10) Primary key,
    long_name varchar(100),
    income_group varchar(50),
    region varchar(50)
);

CREATE TABLE indicators (
    series_code VARCHAR(50) PRIMARY KEY,
    indicator_name VARCHAR(300),
    topic VARCHAR(100)
);

CREATE TABLE debt_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_code VARCHAR(10),
    series_code VARCHAR(50),
    year INT,
    debt_value DOUBLE,
    FOREIGN KEY (country_code) REFERENCES countries(country_code),
    FOREIGN KEY (series_code) REFERENCES indicators(series_code)
);