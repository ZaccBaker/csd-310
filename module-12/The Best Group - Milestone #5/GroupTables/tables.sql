-- Connecting--  to database, might make changes later

-- drop database--  user -- if exists 
DROP USER IF EXIS-- TS 'wine_employee'@'localhost';

-- create movies_user and grant them all privileges to the movies database 
CREATE USER 'wine_employee'@'localhost' IDENTIFIED WITH mysql_native_password BY 'grapes';

-- grant all privileges to the movies database to user movies_user on localhost 
GRANT ALL PRIVILEGES ON winery.* TO 'wine_employee'@'localhost';

-- SET FOREIGN_KEY_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- drop tables if they are present
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS supply_item;
DROP TABLE IF EXISTS supply_inventory;
DROP TABLE IF EXISTS supply_order;
DROP TABLE IF EXISTS wine;
DROP TABLE IF EXISTS forecasted_sales;
DROP TABLE IF EXISTS distributor;
DROP TABLE IF EXISTS wine_order;
DROP TABLE IF EXISTS wineOrder_details;
DROP TABLE IF EXISTS wine_shipment;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS employee_hours;


-- create the supplier table
CREATE TABLE supplier (
    supplier_id             INT             NOT NULL        AUTO_INCREMENT,
    supplier_name           VARCHAR(50)     NOT NULL,
    supplier_phone          VARCHAR(50),
    supplier_address        VARCHAR(50),

    PRIMARY KEY (supplier_id)
);

-- create the supply item table
CREATE TABLE supply_item(
    item_id         INT             NOT NULL        AUTO_INCREMENT,
    item_name       VARCHAR(50)     NOT NULL,
    item_price      INT,  
    supplier_id     INT,

    PRIMARY KEY(item_id),

    CONSTRAINT fk_supplier
    FOREIGN KEY(supplier_id)
        REFERENCES supplier(supplier_id)
);

-- create the supply inventory table
CREATE TABLE supply_inventory(
    inventory_id            INT             NOT NULL    AUTO_INCREMENT,
    inventory_current        INT,
    inventory_reorder       INT,
    inventory_lastUpdated   DATE,
    item_id                 INT             NOT NULL,

    PRIMARY KEY(inventory_id),

    CONSTRAINT fk_item
    FOREIGN KEY(item_id)
        REFERENCES supply_item(item_id)
);

-- create the supply order table
CREATE TABLE supply_order(
    supplyOrder_id        INT          NOT NULL    AUTO_INCREMENT,
    supplyOrder_quantity  INT,
    supplyOrder_date      DATE,
    supplyOrder_expDel    DATE,
    supplyOrder_actDel    DATE,
    supplyOrder_status    VARCHAR(50),
    supplier_id     INT             NOT NULL,
    item_id         INT             NOT NULL,

    PRIMARY KEY(supplyOrder_id),

    CONSTRAINT fk_supply
    FOREIGN KEY(supplier_id)
        REFERENCES supplier(supplier_id),

    CONSTRAINT fk_item2
    FOREIGN KEY(item_id)
        REFERENCES supply_item(item_id)
);

-- create the wine table
CREATE TABLE wine(
    wine_id                 INT             NOT NULL        AUTO_INCREMENT,
    wine_name               VARCHAR(50)     NOT NULL,
    wine_productionCost     INT,
    wine_salePrice          INT,

    PRIMARY KEY(wine_id)
);

-- create the forecasted sales table
CREATE TABLE forecasted_sales(
    forecast_id     INT         NOT NULL        AUTO_INCREMENT,
    forecast_date   DATE,
    forecast_sales  INT,
    wine_id         INT         NOT NULL,

    PRIMARY KEY(forecast_id),

    CONSTRAINT fk_wine
    FOREIGN KEY(wine_id)
        REFERENCES  wine(wine_id)
);

-- create the distributor table
CREATE TABLE distributor(
    distributor_id              INT             NOT NULL        AUTO_INCREMENT,
    distributor_name            VARCHAR(50)     NOT NULL,
    distributor_phone           VARCHAR(50),
    distributor_address         VARCHAR(50),
    distributor_credentials     VARCHAR(50),
    distributor_unitSold        INT,
    wine_id                     INT             NOT NULL,

    PRIMARY KEY(distributor_id),

    CONSTRAINT fk_wine2
    FOREIGN KEY(wine_id)
        REFERENCES  wine(wine_id)
);

-- create the wine order table
CREATE TABLE wine_order(
    wineOrder_id        INT             NOT NULL        AUTO_INCREMENT,
    wineOrder_date      DATE,
    wineOrder_total     INT,
    wineOrder_status    VARCHAR(50),
    distributor_id      INT             NOT NULL,

    PRIMARY KEY(wineOrder_id),

    CONSTRAINT fk_distributor
    FOREIGN KEY(distributor_id)
        REFERENCES distributor(distributor_id)
);

-- create the wine order details table
CREATE TABLE wineOrder_details(
    details_id              INT         NOT NULL        AUTO_INCREMENT,
    details_quantity        INT,
    details_unitPrice       INT,
    wineOrder_id            INT         NOT NULL,
    
    PRIMARY KEY(details_id),

    CONSTRAINT fk_order
    FOREIGN KEY(wineOrder_id)
        REFERENCES wine_order(wineOrder_id)
);

-- create the wine shipment table
CREATE TABLE wine_shipment(
    shipment_id                 INT             NOT NULL        AUTO_INCREMENT,
    shipment_date               DATE,
    shipment_estDel             DATE,
    shipment_tracking           INT             NOT NULL,
    shipment_carrier            VARCHAR(50),
    wineOrder_id                INT             NOT NULL,

    PRIMARY KEY(shipment_id),
    
    CONSTRAINT fk_order2
    FOREIGN KEY(wineOrder_id)
        REFERENCES wine_order(wineOrder_id)
);

-- create the employees table
CREATE TABLE employees(
    employee_id             INT             NOT NULL    AUTO_INCREMENT,
    employee_firstName      VARCHAR(50),
    employee_lastName       VARCHAR(75),
    employee_role           VARCHAR(50),
    employee_hireDate       DATE,
    employee_clearance      VARCHAR(50),

    PRIMARY KEY(employee_id)
);

-- create the employee hours table (no pay type)
CREATE TABLE employee_hours(
    hours_id                INT             NOT NULL        AUTO_INCREMENT,
    hours_dateStart         DATE,
    hours_dateEnd           DATE,
    hours_worked            INT,
    hours_pay               INT,
    employee_id             INT             NOT NULL,

    PRIMARY KEY(hours_id),

    CONSTRAINT fk_employees
    FOREIGN KEY(employee_id)
        REFERENCES employees(employee_id)
);

-- Removing duplicates from employee hours
TRUNCATE TABLE employee_hours;

-- insert supplier records
INSERT INTO supplier(supplier_name, supplier_phone, supplier_address)
    VALUES('SuppliesInc','402.888.1212','1234 Maple Street');

INSERT INTO supplier(supplier_name, supplier_phone, supplier_address)
    VALUES('ContainerGalore','402.951.3000','575 Washington Boulevard');

INSERT INTO supplier(supplier_name, supplier_phone, supplier_address)
    VALUES('WinerySupplies','402.772.2315','9000 Blondo Street');

-- insert supply item
INSERT INTO supply_item(item_name, item_price, supplier_id)
    VALUES('Bottle',5,(SELECT supplier_id FROM supplier WHERE supplier_name = 'SuppliesInc'));

INSERT INTO supply_item(item_name, item_price, supplier_id)
    VALUES('Cork',1,(SELECT supplier_id FROM supplier WHERE supplier_name = 'SuppliesInc'));

INSERT INTO supply_item(item_name, item_price, supplier_id)
    VALUES('Label',2,(SELECT supplier_id FROM supplier WHERE supplier_name = 'ContainerGalore'));

INSERT INTO supply_item(item_name, item_price, supplier_id)
    VALUES('Box',7,(SELECT supplier_id FROM supplier WHERE supplier_name = 'ContainerGalore'));

INSERT INTO supply_item(item_name, item_price, supplier_id)
    VALUES('Vat',22,(SELECT supplier_id FROM supplier WHERE supplier_name = 'WinerySupplies'));

INSERT INTO supply_item(item_name, item_price, supplier_id)
    VALUES('Tubing',10,(SELECT supplier_id FROM supplier WHERE supplier_name = 'WinerySupplies'));

-- insert supply inventory
INSERT INTO supply_inventory(inventory_current, inventory_reorder, inventory_lastUpdated, item_id)
    VALUES(5122,500,'2025-07-12',(SELECT item_id FROM supply_item WHERE item_name = 'Bottle'));

INSERT INTO supply_inventory(inventory_current, inventory_reorder, inventory_lastUpdated, item_id)
    VALUES(2400,2000,'2025-07-12',(SELECT item_id FROM supply_item WHERE item_name = 'Cork'));

INSERT INTO supply_inventory(inventory_current, inventory_reorder, inventory_lastUpdated, item_id)
    VALUES(6124,1200,'2025-07-12',(SELECT item_id FROM supply_item WHERE item_name = 'Label'));

INSERT INTO supply_inventory(inventory_current, inventory_reorder, inventory_lastUpdated, item_id)
    VALUES(1023,515,'2025-07-12',(SELECT item_id FROM supply_item WHERE item_name = 'Box'));

INSERT INTO supply_inventory(inventory_current, inventory_reorder, inventory_lastUpdated, item_id)
    VALUES(820,110,'2025-07-12',(SELECT item_id FROM supply_item WHERE item_name = 'Vat'));

INSERT INTO supply_inventory(inventory_current, inventory_reorder, inventory_lastUpdated, item_id)
    VALUES(4000,100,'2025-07-12',(SELECT item_id FROM supply_item WHERE item_name = 'Tubing'));

-- insert supply order
INSERT INTO supply_order(supplyOrder_quantity, supplyOrder_date, supplyOrder_expDel, supplyOrder_actDel, supplyOrder_status, supplier_id, item_id)
    VALUES(120,'2025-05-12','2025-06-12','2025-06-20', 'Delivered', 
        (SELECT supplier_id FROM supplier WHERE supplier_name = 'SuppliesInc'),
        (SELECT item_id FROM supply_item WHERE item_name = 'Bottle'));

INSERT INTO supply_order(supplyOrder_quantity, supplyOrder_date, supplyOrder_expDel, supplyOrder_actDel, supplyOrder_status, supplier_id, item_id)
    VALUES(200,'2025-05-12','2025-06-12','2025-06-20', 'Delivered', 
        (SELECT supplier_id FROM supplier WHERE supplier_name = 'SuppliesInc'),
        (SELECT item_id FROM supply_item WHERE item_name = 'Cork'));

INSERT INTO supply_order(supplyOrder_quantity, supplyOrder_date, supplyOrder_expDel, supplyOrder_actDel, supplyOrder_status, supplier_id, item_id)
    VALUES(312,'2025-05-12','2025-06-04','2025-06-04', 'Delivered', 
        (SELECT supplier_id FROM supplier WHERE supplier_name = 'ContainerGalore'),
        (SELECT item_id FROM supply_item WHERE item_name = 'Label'));

INSERT INTO supply_order(supplyOrder_quantity, supplyOrder_date, supplyOrder_expDel, supplyOrder_actDel, supplyOrder_status, supplier_id, item_id)
    VALUES(55,'2025-05-12','2025-06-04','2025-06-04', 'Delivered', 
        (SELECT supplier_id FROM supplier WHERE supplier_name = 'ContainerGalore'),
        (SELECT item_id FROM supply_item WHERE item_name = 'Box'));

INSERT INTO supply_order(supplyOrder_quantity, supplyOrder_date, supplyOrder_expDel, supplyOrder_actDel, supplyOrder_status, supplier_id, item_id)
    VALUES(10,'2025-05-12','2025-06-10','2025-06-11', 'Delivered', 
        (SELECT supplier_id FROM supplier WHERE supplier_name = 'WinerySupplies'),
        (SELECT item_id FROM supply_item WHERE item_name = 'Vat'));

INSERT INTO supply_order(supplyOrder_quantity, supplyOrder_date, supplyOrder_expDel, supplyOrder_actDel, supplyOrder_status, supplier_id, item_id)
    VALUES(42,'2025-05-12','2025-06-10','2025-06-11', 'Delivered', 
        (SELECT supplier_id FROM supplier WHERE supplier_name = 'WinerySupplies'),
        (SELECT item_id FROM supply_item WHERE item_name = 'Tubing'));

-- insert wine
INSERT INTO wine(wine_name, wine_productionCost, wine_salePrice)
    VALUES('Merlot', 8, 12);

INSERT INTO wine(wine_name, wine_productionCost, wine_salePrice)
    VALUES('Cabernet', 5, 10);

INSERT INTO wine(wine_name, wine_productionCost, wine_salePrice)
    VALUES('Chablis', 10, 19);

INSERT INTO wine(wine_name, wine_productionCost, wine_salePrice)
    VALUES('Chardonnay', 9, 20);

-- insert forecasted sales
INSERT INTO forecasted_sales(forecast_date, forecast_sales, wine_id)
    VALUES('2025-07-12', 6000, (SELECT wine_id FROM wine WHERE wine_name = 'Merlot'));

INSERT INTO forecasted_sales(forecast_date, forecast_sales, wine_id)
    VALUES('2025-07-12', 5180, (SELECT wine_id FROM wine WHERE wine_name = 'Cabernet'));

INSERT INTO forecasted_sales(forecast_date, forecast_sales, wine_id)
    VALUES('2025-07-12', 9690, (SELECT wine_id FROM wine WHERE wine_name = 'Chablis'));

INSERT INTO forecasted_sales(forecast_date, forecast_sales, wine_id)
    VALUES('2025-07-12', 8000, (SELECT wine_id FROM wine WHERE wine_name = 'Chardonnay'));

-- insert distributor
INSERT INTO distributor(distributor_name, distributor_phone, distributor_address, distributor_credentials, distributor_unitSold, wine_id)
    VALUES('WineBrothers', '402.154.1515', '1231 Monroe Street', 'License#A12', 520, (SELECT wine_id FROM wine WHERE wine_name = 'Merlot'));

INSERT INTO distributor(distributor_name, distributor_phone, distributor_address, distributor_credentials, distributor_unitSold, wine_id)
    VALUES('GoldenDistribution', '402.789.5465', '5438 Jefferson Street', 'License#B22', 613, (SELECT wine_id FROM wine WHERE wine_name = 'Cabernet'));

INSERT INTO distributor(distributor_name, distributor_phone, distributor_address, distributor_credentials, distributor_unitSold, wine_id)
    VALUES('QualityWine', '402.789.5465', '5438 Jefferson Street', 'License#C33', 321, (SELECT wine_id FROM wine WHERE wine_name = 'Chardonnay'));


-- insert wine order
INSERT INTO wine_order(wineOrder_date, wineOrder_total, wineOrder_status, distributor_id)
    VALUES('2025-07-03', 8600, 'Shipping', (SELECT distributor_id FROM distributor WHERE distributor_name = 'WineBrothers'));

INSERT INTO wine_order(wineOrder_date, wineOrder_total, wineOrder_status, distributor_id)
    VALUES('2025-07-06', 9850, 'Shipping', (SELECT distributor_id FROM distributor WHERE distributor_name = 'GoldenDistribution'));

INSERT INTO wine_order(wineOrder_date, wineOrder_total, wineOrder_status, distributor_id)
    VALUES('2025-07-06', 3500, 'Shipping', (SELECT distributor_id FROM distributor WHERE distributor_name = 'QualityWine'));

-- insert wine order details
INSERT INTO wineOrder_details(details_quantity, details_unitPrice, wineOrder_id)
    VALUES(700, 12, (SELECT wineOrder_id FROM wine_order WHERE wineOrder_total = 8600));

INSERT INTO wineOrder_details(details_quantity, details_unitPrice, wineOrder_id)
    VALUES(940, 15, (SELECT wineOrder_id FROM wine_order WHERE wineOrder_total = 9850));

INSERT INTO wineOrder_details(details_quantity, details_unitPrice, wineOrder_id)
    VALUES(350, 19, (SELECT wineOrder_id FROM wine_order WHERE wineOrder_total = 3500));

-- insert wine shipment
INSERT INTO wine_shipment(shipment_date, shipment_estDel, shipment_tracking, wineOrder_id)
    VALUES('2025-07-13', '2025-07-23', 1554894321, 1);

INSERT INTO wine_shipment(shipment_date, shipment_estDel, shipment_tracking, wineOrder_id)
    VALUES('2025-07-16', '2025-07-26', 1557414354, 2);

INSERT INTO wine_shipment(shipment_date, shipment_estDel, shipment_tracking, wineOrder_id)
    VALUES('2025-07-13', '2025-07-23', 1559994322, 3);

-- insert employees
INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Stan', 'Bacchus', 'Co-CEO', '2023-07-12', 'True');

INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Davis', 'Bacchus', 'Co-CEO', '2023-07-12', 'True');

INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Janet', 'Collins', 'Finance Manager', '2023-12-22', 'True');

INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Roz', 'Murphy', 'Marketing Manager', '2023-12-23', 'True');

INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Bob', 'Ulrich', 'Marketing Associate', '2024-01-05', 'False');

INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Henry', 'Doyle', 'Production Manager', '2023-08-07', 'True');

INSERT INTO employees(employee_firstName, employee_lastName, employee_role, employee_hireDate, employee_clearance)
    VALUES('Maria', 'Costanza', 'Distribution Manager', '2024-02-15', 'True');

-- insert employee hours (no pay type)
--- Qaurter 2 (2025)
INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 412, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Stan'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 405, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Davis'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 410, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Janet'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 377, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Roz'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 450, 18, (SELECT employee_id FROM employees WHERE employee_firstName = 'Bob'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 410, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Henry'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-04-01', '2025-06-30', 433, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Maria'));

--- Quarter 1 (2025)
INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 432, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Stan'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 445, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Davis'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 384, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Janet'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 412, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Roz'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 398, 18, (SELECT employee_id FROM employees WHERE employee_firstName = 'Bob'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 458, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Henry'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2025-01-01', '2025-03-31', 431, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Maria'));

--- Quarter 4 (2024)
INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 455, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Stan'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 441, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Davis'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 405, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Janet'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 395, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Roz'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 320, 18, (SELECT employee_id FROM employees WHERE employee_firstName = 'Bob'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 415, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Henry'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-10-01', '2024-12-31', 441, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Maria'));

-- Qaurter 3 (2024)
INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 348, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Stan'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 378, 30, (SELECT employee_id FROM employees WHERE employee_firstName = 'Davis'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 422, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Janet'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 436, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Roz'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 404, 18, (SELECT employee_id FROM employees WHERE employee_firstName = 'Bob'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 379, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Henry'));

INSERT INTO employee_hours(hours_dateStart, hours_dateEnd, hours_worked, hours_pay, employee_id)
    VALUES('2024-7-01', '2024-9-30', 429, 25, (SELECT employee_id FROM employees WHERE employee_firstName = 'Maria'));