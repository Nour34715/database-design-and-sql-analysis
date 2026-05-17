use `48713406` ;
-- Nour Yacoub - 48713406

-- Task B: CREATE TABLES

-- Table: CustomerType
CREATE TABLE CustomerType (
    customerTypeID INT PRIMARY KEY,
    customerTypeName VARCHAR(45) NOT NULL,
    customerTypeDescription TEXT
);

-- Table: Customer
CREATE TABLE Customer (
    customerID INT PRIMARY KEY,
    customerName VARCHAR(300) NOT NULL,
    contactName VARCHAR(300),
    customerPhoneNumber VARCHAR(20),
    customerAddress VARCHAR(500),
    customerTypeID INT,
    FOREIGN KEY (customerTypeID) REFERENCES CustomerType(customerTypeID)
);

-- Table: StaffMember
CREATE TABLE StaffMember (
    staffID INT PRIMARY KEY,
    staffName VARCHAR(300) NOT NULL,
    staffRole VARCHAR(30),
    staffCurrentEmployeeType VARCHAR(20)
);

-- Table: Order
CREATE TABLE `Order` (
    orderID INT PRIMARY KEY,
    orderDate DATE NOT NULL,
    orderTime TIME NOT NULL,
    orderDeliveryInstructions TEXT,
    customerID INT NOT NULL,
    createdByStaffID INT NOT NULL,
    FOREIGN KEY (customerID) REFERENCES Customer(customerID),
    FOREIGN KEY (createdByStaffID) REFERENCES StaffMember(staffID)
);

-- Table: OrderItem
CREATE TABLE OrderItem (
    orderID INT NOT NULL,
    itemSequenceNumber INT NOT NULL,
    quantity INT NOT NULL,
    salePricePerItem DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (orderID, itemSequenceNumber),
    FOREIGN KEY (orderID) REFERENCES `Order`(orderID)
);

-- Table: Payment
CREATE TABLE Payment (
    paymentID INT PRIMARY KEY,
    paymentAmount DECIMAL(10,2) NOT NULL,
    paymentDateTime DATETIME NOT NULL,
    paymentMethod VARCHAR(20),
    paymentSystemReferenceNumber VARCHAR(256)
);

-- Table: PaymentPortion
CREATE TABLE PaymentPortion (
    paymentID INT NOT NULL,
    orderID INT NOT NULL,
    paymentPortionAmount DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (paymentID, orderID),
    FOREIGN KEY (paymentID) REFERENCES Payment(paymentID),
    FOREIGN KEY (orderID) REFERENCES `Order`(orderID)
);


-- Insert into CustomerType
INSERT INTO CustomerType VALUES
(1, 'Individual', 'Single person ordering'),
(2, 'Company', 'Business account');

-- Insert into Customer
INSERT INTO Customer VALUES
(1, 'Alice Smith', 'Alice Smith', '0412345678', '123 Main St', 1),
(2, 'Zara Interiors', 'Zara Lee', '0498765432', '456 High St', 2),
(3, 'Bob Johnson', 'Bob Johnson', '0411222333', '789 Park Rd', 1);

-- Insert into StaffMember
INSERT INTO StaffMember VALUES
(1, 'Jane Doe', 'Sales Rep', 'Full-time'),
(2, 'Tom Lee', 'Manager', 'Part-time');

-- Insert into Order
INSERT INTO `Order` VALUES
(1, '2023-03-10', '09:30:00', 'Leave at door', 1, 1),
(2, '2024-05-15', '14:00:00', 'Deliver upstairs', 2, 1),
(3, '2025-02-20', '10:15:00', 'Handle with care', 3, 2);

-- Insert into OrderItem
INSERT INTO OrderItem VALUES
(1, 1, 2, 150.00),
(1, 2, 1, 200.00),
(2, 1, 3, 75.00),
(3, 1, 1, 500.00);

-- Insert into Payment
INSERT INTO Payment VALUES
(1, 500.00, '2023-03-12 11:00:00', 'CreditCard', 'REF123'),
(2, 100.00, '2024-05-16 15:30:00', 'PayPal', 'PP987'),
(3, 250.00, '2025-02-21 12:00:00', 'BankTransfer', 'BT456');

-- Insert into PaymentPortion
INSERT INTO PaymentPortion VALUES
(1, 1, 350.00),
(1, 2, 150.00),
(2, 2, 100.00),
(3, 3, 250.00);

-- Task C (i)

SELECT customerID, customerName, customerPhoneNumber, customerAddress
FROM Customer
WHERE customerName LIKE '%a%' OR customerName LIKE '%z%'
ORDER BY customerName DESC;


-- Task C (ii)

SELECT c.customerID, c.customerName, MIN(o.orderDate) AS firstOrderDate
FROM Customer c
LEFT JOIN `Order` o ON c.customerID = o.customerID
GROUP BY c.customerID, c.customerName;




-- Task C (iii)
SELECT o.orderID,
       o.orderDate,
       o.orderTime,
       c.customerName,
       c.contactName,
       SUM(oi.quantity * oi.salePricePerItem) AS totalAmount
FROM `Order` o
JOIN Customer c ON o.customerID = c.customerID
JOIN OrderItem oi ON o.orderID = oi.orderID
GROUP BY o.orderID, o.orderDate, o.orderTime, c.customerName, c.contactName
ORDER BY o.orderDate ASC, c.customerID DESC;

-- Task C (iv)
SELECT o.orderID,
       COALESCE(SUM(pp.paymentPortionAmount), 0) AS totalPaid
FROM `Order` o
LEFT JOIN PaymentPortion pp ON o.orderID = pp.orderID
GROUP BY o.orderID;


-- Task C (v)
SELECT s.staffID,
       s.staffName,
       y.year,
       COALESCE(COUNT(o.orderID), 0) AS numberOfOrders
FROM StaffMember s
CROSS JOIN (
    SELECT 2021 AS year UNION
    SELECT 2022 UNION
    SELECT 2023 UNION
    SELECT 2024 UNION
    SELECT 2025
) y
LEFT JOIN `Order` o
       ON o.createdByStaffID = s.staffID
       AND YEAR(o.orderDate) = y.year
GROUP BY s.staffID, s.staffName, y.year
ORDER BY s.staffID, y.year;

-- Task C (vi)
SELECT o.orderID,
       SUM(oi.quantity * oi.salePricePerItem) AS totalOrderAmount,
       COALESCE(SUM(pp.paymentPortionAmount), 0) AS totalPaid,
       SUM(oi.quantity * oi.salePricePerItem) - COALESCE(SUM(pp.paymentPortionAmount), 0) AS totalOwing
FROM `Order` o
JOIN OrderItem oi ON o.orderID = oi.orderID
LEFT JOIN PaymentPortion pp ON o.orderID = pp.orderID
GROUP BY o.orderID;




