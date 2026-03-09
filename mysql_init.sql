-- ============================================================================
-- SEMSAS - Smart Expiry Management & Shelf Alert System
-- MySQL Database Initialization File

USE StoreManagement;

-- Drop existing tables if they exist (in correct order to avoid FK constraints)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Promotion;
DROP TABLE IF EXISTS Price_History;
DROP TABLE IF EXISTS Alert;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Batch_Lot;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Shelf;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Brand;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Store;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 1. TABLE CREATION
-- ============================================================================

-- Store Table
CREATE TABLE Store (
    Store_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Address TEXT,
    Contact_Info VARCHAR(100)
);

-- Category Table
CREATE TABLE Category (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(50)
);

-- Brand Table
CREATE TABLE Brand (
    Brand_ID INT PRIMARY KEY,
    Brand_Name VARCHAR(50)
);

-- Product Table
CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Current_Price DECIMAL(10, 2),
    Category_ID INT,
    Brand_ID INT,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID),
    FOREIGN KEY (Brand_ID) REFERENCES Brand(Brand_ID)
);

-- Shelf Table
CREATE TABLE Shelf (
    Shelf_ID INT PRIMARY KEY,
    Store_ID INT,
    Shelf_Location VARCHAR(50),
    Capacity INT,
    Temperature_Type VARCHAR(50),
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID)
);

-- Employee Table
CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    Store_ID INT,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Shift_Time VARCHAR(50),
    Contact_Number VARCHAR(20),
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID)
);

-- Batch_Lot Table
CREATE TABLE Batch_Lot (
    Batch_Lot_ID INT PRIMARY KEY,
    Product_ID INT,
    Expiry_Date DATE,
    Cost_Price DECIMAL(10, 2),
    Received_Quantity INT,
    Received_Date DATE,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- Inventory Table
CREATE TABLE Inventory (
    Inventory_ID INT PRIMARY KEY,
    Batch_Lot_ID INT,
    Shelf_ID INT,
    Quantity INT,
    Restock_Date DATE,
    Status VARCHAR(50),
    FOREIGN KEY (Batch_Lot_ID) REFERENCES Batch_Lot(Batch_Lot_ID),
    FOREIGN KEY (Shelf_ID) REFERENCES Shelf(Shelf_ID)
);

-- Alert Table
CREATE TABLE Alert (
    Alert_ID INT PRIMARY KEY,
    Batch_Lot_ID INT,
    Employee_ID INT,
    Alert_Date DATE,
    Alert_Type VARCHAR(50),
    Status VARCHAR(50),
    FOREIGN KEY (Batch_Lot_ID) REFERENCES Batch_Lot(Batch_Lot_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);

-- Price_History Table
CREATE TABLE Price_History (
    Price_History_ID INT PRIMARY KEY,
    Product_ID INT,
    Employee_ID INT,
    Old_Price DECIMAL(10, 2),
    New_Price DECIMAL(10, 2),
    Change_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);

-- Promotion Table
CREATE TABLE Promotion (
    Promotion_ID INT PRIMARY KEY,
    Promotion_Name VARCHAR(100),
    Start_Date DATE,
    End_Date DATE,
    Discount_Type VARCHAR(20),
    Discount_Value DECIMAL(10, 2),
    Product_ID INT NULL,
    Category_ID INT NULL,
    Brand_ID INT NULL,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID),
    FOREIGN KEY (Brand_ID) REFERENCES Brand(Brand_ID)
);

-- Users Table (for authentication)
CREATE TABLE Users (
    User_ID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password_Hash VARCHAR(255) NOT NULL,
    Role ENUM('admin', 'manager', 'demo') NOT NULL,
    Store_ID INT NULL,
    Full_Name VARCHAR(100) NOT NULL,
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID)
);

-- ============================================================================
-- 2. SAMPLE DATA INSERTION
-- ============================================================================

-- Stores
INSERT IGNORE INTO Store VALUES (6517, 'Dolayoba M', 'Dolayoba Street', '850 224 6517');
INSERT IGNORE INTO Store VALUES (5244, 'Esref Bitlis Mjet', 'Esref Bitlis Boulevard', '850 225 5244');
INSERT IGNORE INTO Store VALUES (3277, 'Velibaba Mjet', 'Velibaba Street', '850 226 3277');
INSERT IGNORE INTO Store VALUES (4456, 'Bosna Mjet', 'Bosna Boulevard', '850 227 4456');
INSERT IGNORE INTO Store VALUES (8696, 'Baku M', 'Baku Street', '850 228 8696');

-- Categories
INSERT IGNORE INTO Category VALUES 
(1, 'Dairy'), 
(2, 'Beverages'), 
(3, 'Snacks'), 
(4, 'Bakery'), 
(5, 'Produce');

-- Brands
INSERT IGNORE INTO Brand VALUES 
(1, 'Nestle'), 
(2, 'Coca-Cola'), 
(3, 'Farmer Fresh'), 
(4, 'BakeHouse'), 
(5, 'OrganicValley');

-- Products
INSERT IGNORE INTO Product VALUES (101, 'Whole Milk 1L', 3.50, 1, 3);
INSERT IGNORE INTO Product VALUES (102, 'Greek Yogurt', 4.20, 1, 3);
INSERT IGNORE INTO Product VALUES (103, 'Diet Coke 330ml', 1.50, 2, 2);
INSERT IGNORE INTO Product VALUES (104, 'Orange Juice', 3.00, 2, 5);
INSERT IGNORE INTO Product VALUES (105, 'Chocolate Bar', 2.00, 3, 1);
INSERT IGNORE INTO Product VALUES (106, 'Potato Chips', 2.50, 3, 1);
INSERT IGNORE INTO Product VALUES (107, 'Whole Wheat Bread', 1.80, 4, 4);
INSERT IGNORE INTO Product VALUES (108, 'Croissant', 1.20, 4, 4);
INSERT IGNORE INTO Product VALUES (109, 'Organic Apples 1kg', 5.00, 5, 5);
INSERT IGNORE INTO Product VALUES (110, 'Bananas 1kg', 2.20, 5, 5);

-- Shelves
INSERT IGNORE INTO Shelf (Shelf_ID, Store_ID, Shelf_Location, Capacity, Temperature_Type) VALUES 
(501, 6517, 'Aisle 1 - Fridge', 100, 'Refrigerated'),
(502, 6517, 'Aisle 2 - Dry Goods', 200, 'Ambient'),
(503, 6517, 'Aisle 3 - Bakery', 50, 'Ambient'),
(504, 6517, 'Aisle 4 - Freezer', 80, 'Frozen'),
(505, 6517, 'Aisle 5 - Produce', 150, 'Ambient'),
(506, 5244, 'Aisle 1 - Dry Goods', 250, 'Ambient'),
(507, 5244, 'Aisle 2 - Fridge', 120, 'Refrigerated'),
(508, 5244, 'Aisle 3 - Freezer', 70, 'Frozen'),
(509, 5244, 'Aisle 4 - Bakery', 60, 'Ambient'),
(510, 5244, 'Aisle 5 - Cleaning Supplies', 100, 'Ambient'),
(511, 3277, 'Aisle 1 - Produce', 180, 'Ambient'),
(512, 3277, 'Aisle 2 - Snacks', 300, 'Ambient'),
(513, 3277, 'Aisle 3 - Fridge', 90, 'Refrigerated'),
(514, 3277, 'Aisle 4 - Beverages', 200, 'Ambient'),
(515, 3277, 'Aisle 5 - Freezer', 50, 'Frozen'),
(516, 4456, 'Aisle 1 - Dairy Fridge', 150, 'Refrigerated'),
(517, 4456, 'Aisle 2 - Canned Food', 200, 'Ambient'),
(518, 4456, 'Aisle 3 - Meat Fridge', 100, 'Refrigerated'),
(519, 4456, 'Aisle 4 - Bakery & Sweets', 120, 'Ambient'),
(520, 4456, 'Aisle 5 - Frozen Meals', 100, 'Frozen'),
(521, 8696, 'Aisle 1 - Bulk Goods', 500, 'Ambient'),
(522, 8696, 'Aisle 2 - International Food', 150, 'Ambient'),
(523, 8696, 'Aisle 3 - Gourmet Fridge', 80, 'Refrigerated'),
(524, 8696, 'Aisle 4 - Pet Food', 100, 'Ambient'),
(525, 8696, 'Aisle 5 - Drinks', 250, 'Ambient');

-- Employees
INSERT IGNORE INTO Employee (Employee_ID, Store_ID, Name, Position, Shift_Time, Contact_Number) VALUES 
(1, 6517, 'Birol Sezer', 'Manager', 'Morning', '555-1001'),
(2, 6517, 'Helin Ozkan', 'Assistant Manager', 'Evening', '555-1002'),
(3, 6517, 'Devran Duman', 'Clerk', 'Morning', '555-1003'),
(4, 6517, 'Dilan Kaya', 'Clerk', 'Evening', '555-1004'),
(5, 5244, 'Temel Reis', 'Manager', 'Morning', '555-2001'),
(6, 5244, 'Efrahim Ozer', 'Assistant Manager', 'Evening', '555-2002'),
(7, 5244, 'Eflal Kurtbas', 'Clerk', 'Morning', '555-2003'),
(8, 5244, 'Dilara Aydin', 'Clerk', 'Evening', '555-2004'),
(9, 3277, 'Sefacan Ozgun', 'Manager', 'Morning', '555-3001'),
(10, 3277, 'Elif Akkaya', 'Assistant Manager', 'Evening', '555-3002'),
(11, 3277, 'Fatma Atan', 'Clerk', 'Morning', '555-3003'),
(12, 3277, 'Furkan Karabas', 'Clerk', 'Evening', '555-3004'),
(13, 4456, 'Bektas Baltaci', 'Manager', 'Morning', '555-4001'),
(14, 4456, 'Metin Ozturk', 'Assistant Manager', 'Evening', '555-4002'),
(15, 4456, 'Enes Kayhan', 'Clerk', 'Morning', '555-4003'),
(16, 4456, 'Selcan Hurafe', 'Clerk', 'Evening', '555-4004'),
(17, 8696, 'Kadir Ozyilmaz', 'Manager', 'Morning', '555-5001'),
(18, 8696, 'Ridvan Aksu', 'Assistant Manager', 'Evening', '555-5002'),
(19, 8696, 'Melike Unal', 'Clerk', 'Morning', '555-5003'),
(20, 8696, 'Erdem Kurt', 'Clerk', 'Evening', '555-5004');

-- Batch Lots
INSERT IGNORE INTO Batch_Lot (Batch_Lot_ID, Product_ID, Expiry_Date, Cost_Price, Received_Quantity, Received_Date) VALUES 
(901, 101, '2025-12-25', 2.10, 100, '2025-12-10'), 
(902, 102, '2025-12-20', 2.50, 80, '2025-12-10'), 
(903, 103, '2026-06-01', 0.80, 200, '2025-12-01'), 
(904, 107, '2025-12-21', 1.00, 50, '2025-12-18'), 
(905, 110, '2025-12-19', 1.20, 120, '2025-12-15'),
(906, 101, '2026-02-15', 2.20, 150, '2025-12-16'),
(907, 105, '2025-12-20', 5.50, 10, '2025-12-12'),
(908, 108, '2025-12-18', 0.90, 5, '2025-12-17'),
(909, 104, '2026-08-20', 3.00, 300, '2025-12-01'),
(910, 109, '2025-12-24', 1.50, 45, '2025-12-15'),
(911, 102, '2026-01-10', 2.50, 60, '2025-12-17'),
(912, 110, '2025-12-22', 1.25, 15, '2025-12-17');

-- Inventory
INSERT IGNORE INTO Inventory (Inventory_ID, Batch_Lot_ID, Shelf_ID, Quantity, Restock_Date, Status) VALUES 
(1, 901, 501, 40, '2025-12-10', 'On Shelf'),
(2, 903, 502, 100, '2025-12-01', 'On Shelf'),
(3, 908, 503, 5, '2025-12-17', 'On Shelf'),
(4, 902, 501, 20, '2025-12-10', 'On Shelf'),
(5, 905, 505, 60, '2025-12-15', 'On Shelf'),
(6, 907, 506, 10, '2025-12-12', 'On Shelf'),
(7, 902, 507, 40, '2025-12-10', 'On Shelf'),
(8, 911, 507, 60, '2025-12-17', 'In Warehouse'),
(9, 904, 509, 25, '2025-12-18', 'On Shelf'),
(10, 906, 507, 50, '2025-12-16', 'On Shelf'),
(11, 910, 511, 45, '2025-12-15', 'On Shelf'),
(12, 912, 511, 15, '2025-12-17', 'On Shelf'),
(13, 903, 514, 100, '2025-12-01', 'On Shelf'),
(14, 907, 512, 10, '2025-12-12', 'On Shelf'),
(15, 911, 513, 30, '2025-12-17', 'On Shelf'),
(16, 906, 516, 100, '2025-12-16', 'On Shelf'),
(17, 904, 519, 25, '2025-12-18', 'On Shelf'),
(18, 909, 516, 150, '2025-12-01', 'On Shelf'),
(19, 901, 518, 60, '2025-12-10', 'On Shelf'),
(20, 902, 516, 20, '2025-12-10', 'In Warehouse'),
(21, 903, 525, 100, '2025-12-01', 'On Shelf'),
(22, 905, 521, 60, '2025-12-15', 'On Shelf'),
(23, 910, 521, 30, '2025-12-15', 'On Shelf'),
(24, 901, 523, 50, '2025-12-10', 'On Shelf'),
(25, 911, 523, 30, '2025-12-17', 'In Warehouse');

-- Alerts
INSERT IGNORE INTO Alert (Alert_ID, Batch_Lot_ID, Employee_ID, Alert_Date, Alert_Type, Status) VALUES 
(1, 908, 1, '2025-12-18', 'Critical Expiry', 'Pending'),
(2, 905, 2, '2025-12-18', 'Expiry Warning', 'Pending'),
(3, 902, 3, '2025-12-17', 'Low Stock', 'Resolved'),
(4, 902, 5, '2025-12-18', 'Expiry Warning', 'Pending'),
(5, 907, 6, '2025-12-18', 'Low Stock', 'In Progress'),
(6, 911, 7, '2025-12-17', 'Damage Report', 'Resolved'),
(7, 912, 9, '2025-12-18', 'Expiry Warning', 'Pending'),
(8, 910, 10, '2025-12-18', 'Expiry Warning', 'Pending'),
(9, 903, 11, '2025-12-16', 'Low Stock', 'Resolved'),
(10, 904, 13, '2025-12-18', 'Expiry Warning', 'Pending'),
(11, 906, 14, '2025-12-18', 'Inventory Check', 'Pending'),
(12, 909, 15, '2025-12-15', 'Low Stock', 'Resolved'),
(13, 901, 17, '2025-12-18', 'Expiry Warning', 'Pending'),
(14, 911, 18, '2025-12-18', 'Price Update', 'In Progress'),
(15, 907, 19, '2025-12-17', 'Damage Report', 'Resolved');

-- Price History
INSERT IGNORE INTO Price_History (Price_History_ID, Product_ID, Employee_ID, Old_Price, New_Price, Change_Date) VALUES 
(1, 101, 1, 3.20, 3.50, '2025-12-10 09:00:00'),
(2, 108, 2, 1.50, 1.20, '2025-12-18 10:00:00'),
(3, 110, 2, 2.50, 2.20, '2025-12-17 11:30:00'),
(4, 102, 5, 4.00, 4.20, '2025-12-12 08:45:00'),
(5, 105, 6, 2.20, 2.00, '2025-12-15 14:00:00'),
(6, 107, 6, 2.00, 1.80, '2025-12-18 09:15:00'),
(7, 109, 9, 4.80, 5.00, '2025-12-14 10:00:00'),
(8, 103, 10, 1.70, 1.50, '2025-12-16 16:30:00'),
(9, 110, 10, 2.40, 2.20, '2025-12-17 12:00:00'),
(10, 101, 13, 3.40, 3.50, '2025-12-11 09:30:00'),
(11, 104, 14, 3.20, 3.00, '2025-12-15 15:45:00'),
(12, 107, 14, 1.90, 1.80, '2025-12-18 08:00:00'),
(13, 106, 17, 2.30, 2.50, '2025-12-05 10:00:00'),
(14, 102, 18, 4.50, 4.20, '2025-12-18 11:20:00'),
(15, 105, 18, 2.10, 2.00, '2025-12-17 13:00:00');

-- Promotions
INSERT IGNORE INTO Promotion (Promotion_ID, Promotion_Name, Start_Date, End_Date, Discount_Type, Discount_Value, Product_ID, Category_ID, Brand_ID) VALUES 
(1, 'Urgent: Last 2 Days - 50% OFF', '2025-12-18', '2025-12-18', 'Percentage', 50.00, 108, NULL, NULL),
(2, 'Urgent: Last 2 Days - 50% OFF', '2025-12-18', '2025-12-20', 'Percentage', 50.00, 102, NULL, NULL),
(3, 'Urgent: Last 2 Days - 50% OFF', '2025-12-18', '2025-12-20', 'Percentage', 50.00, 105, NULL, NULL),
(4, 'Urgent: Last 2 Days - 50% OFF', '2025-12-18', '2025-12-19', 'Percentage', 50.00, 110, NULL, NULL),
(5, 'Short Dated - 25% OFF', '2025-12-18', '2025-12-21', 'Percentage', 25.00, 107, NULL, NULL),
(6, 'Short Dated - 25% OFF', '2025-12-18', '2025-12-22', 'Percentage', 25.00, 110, NULL, NULL),
(7, 'Short Dated - 25% OFF', '2025-12-18', '2025-12-24', 'Percentage', 25.00, 109, NULL, NULL),
(8, 'Short Dated - 25% OFF', '2025-12-18', '2025-12-25', 'Percentage', 25.00, 101, NULL, NULL),
(9, 'New Year Beverage Fest', '2025-12-15', '2026-01-05', 'Percentage', 15.00, NULL, 2, NULL),
(10, 'Coca-Cola Special Week', '2025-12-14', '2025-12-21', 'Percentage', 30.00, NULL, NULL, 2);

-- ============================================================================
-- 3. USERS TABLE (Authentication)
-- ============================================================================
-- Admin user: username = admin, password = admin5234
-- Manager users: username = [store_id], password = manager[store_id]
-- Demo user: username = demo, password = demo
-- Password hashes are generated with bcrypt

INSERT IGNORE INTO Users (User_ID, Username, Password_Hash, Role, Store_ID, Full_Name) VALUES
(1, 'admin', '$2b$12$qokXbBJ3U2AYa2cG7kMHAuVfHzDc1ogZmcQ9c/JH90gJT2.37CjXS', 'admin', NULL, 'System Administrator'),
(2, '3277', '$2b$12$mFv35.9LfL2591KmZ1J/NOxpPfYrFfWQ4u65tIAfXh9HpPh69RHie', 'manager', 3277, 'Sefacan Ozgun'),
(3, '4456', '$2b$12$npOY8VYzYq.zIdlDqAqHT.d/uvLcbs3Nsj9Kf4uKZV3Xa046sqRqy', 'manager', 4456, 'Bektas Baltaci'),
(4, '5244', '$2b$12$u.orn2YIIgo.hfX.P9w6t.lXkPvaXMxjAxoeiXbKqPMpt29ZsPX8y', 'manager', 5244, 'Temel Reis'),
(5, '6517', '$2b$12$dWGMPcIeHsESwmgGIhMDfuBvx5tN6HZp0Cv7rwvU.4djEQGMGbuRS', 'manager', 6517, 'Birol Sezer'),
(6, '8696', '$2b$12$MWJXvIn1.zytzCzYJ24xxO.2WvDVNvkHU6cirRy.PKnGNWDhQ49uS', 'manager', 8696, 'Kadir Ozyilmaz'),
(7, 'demo', '$2b$12$4m7.XF.98T5w/G9QeO7oSuQvQkZRY/NIfb0hM8rN2h24N/E5ZJ29S', 'demo', NULL, 'Demo User');

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================