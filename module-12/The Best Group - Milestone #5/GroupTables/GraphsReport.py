#Team Members: Joel Atkinson, Zachary Baker, Kyle Klausen, Juan Macias Vasquez, Brittaney Perry-Morgan
# Date 07/20/2025
# Module 11.1 Group1 Winery New Tables
# GtaphsReport.py

import mysql.connector
import re

# Database configuration
DB_HOST = 'localhost'
DB_USER = 'wine_employee'
DB_PASSWORD = 'grapes' # replace with your own password
DB_NAME = 'winery'


# CONNECT TO MYSQL
conn = mysql.connector.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD
)
cursor = conn.cursor()

# CREATE DATABASE IF NEEDED
cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
conn.database = DB_NAME

# LOAD AND CLEAN SQL FILE
with open('tables.sql', 'r') as f:
    sql = f.read()

# Get rid of full-line comments
sql = re.sub(r'--.*', '', sql)

# Get rid of DROP statements
sql = re.sub(r'DROP TABLE IF EXISTS .*?;', '', sql, flags=re.IGNORECASE)
sql = re.sub(r'DROP USER IF EXISTS .*?;', '', sql, flags=re.IGNORECASE)

# Remove the user and privilege management
sql = re.sub(r"(CREATE|DROP|GRANT) USER .*?;", "", sql, flags=re.IGNORECASE)

# Replace CREATE TABLE with CREATE TABLE IF NOT EXISTS
sql = re.sub(r'CREATE TABLE ', 'CREATE TABLE IF NOT EXISTS ', sql, flags=re.IGNORECASE)

# Add the LIMIT of 1
sql = re.sub(r"\((SELECT .*?WHERE .*?)\)", r"(\1 LIMIT 1)", sql, flags=re.IGNORECASE)

# Split the SQL into individual statements
statements = [s.strip() + ';' for s in sql.split(';') if s.strip()]


# EXECUTE SQL STATEMENTS 
print("Executing SQL statements...")
for stmt in statements:
    try:
        cursor.execute(stmt)
    except mysql.connector.Error as err:
        print("Error:", err)

conn.commit()

# REPORT SECTION 
def print_header(title):
    print("\n" + title)
    print("=" * len(title))

def print_table(headers, rows):
    col_widths = [len(h) for h in headers]
    for row in rows:
        for i in range(len(row)):
            col_widths[i] = max(col_widths[i], len(str(row[i])))
    header_line = " | ".join(headers[i].ljust(col_widths[i]) for i in range(len(headers)))
    print(header_line)
    print("-" * len(header_line))
    for row in rows:
        print(" | ".join(str(row[i]).ljust(col_widths[i]) for i in range(len(row))))

# 1. Supplier Delivery Performance with Delay Gap
print_header("1. Supplier Delivery Performance (Delay Gap in Days)")
query1 = """
SELECT 
    s.supplier_name,
    MONTH(o.supplyOrder_expDel) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.supplyOrder_actDel > o.supplyOrder_expDel THEN 1 ELSE 0 END) AS late_orders,
    ROUND(AVG(CASE 
        WHEN o.supplyOrder_actDel > o.supplyOrder_expDel 
        THEN DATEDIFF(o.supplyOrder_actDel, o.supplyOrder_expDel)
        ELSE NULL
    END), 1) AS avg_delay_days
FROM supply_order o
JOIN supplier s ON o.supplier_id = s.supplier_id
GROUP BY s.supplier_name, MONTH(o.supplyOrder_expDel)
ORDER BY s.supplier_name, month;
"""
cursor.execute(query1)
print_table(["Supplier", "Month", "Total Orders", "Late Orders", "Avg Delay (Days)"], cursor.fetchall())


# 2a. Wine Distribution
print_header("2. Wine Distribution (Wine -> Distributor)")
query2a = """
SELECT w.wine_name, d.distributor_name
FROM wine w
JOIN distributor d ON w.wine_id = d.wine_id
ORDER BY w.wine_name;
"""
cursor.execute(query2a)
print_table(["Wine", "Distributor"], cursor.fetchall())

# 2b. Wine Sales
print_header("2b. Wine Sales")
query2b = """
SELECT w.wine_name,
       COUNT(wo.wineOrder_id) AS orders
FROM wine w
LEFT JOIN distributor d ON w.wine_id = d.wine_id
LEFT JOIN wine_order wo ON d.distributor_id = wo.distributor_id
GROUP BY w.wine_name
ORDER BY orders ASC;
"""
cursor.execute(query2b)
print_table(["Wine", "Orders"], cursor.fetchall())

# 3. Employee Hours by Quarter (Last 4 Quarters + Totals)
print_header("3. Employee Hours by Quarter (Last 4 Quarters + Totals)")
query3 = """
SELECT 
    CONCAT(e.employee_firstName, ' ', e.employee_lastName) AS employee,
    CONCAT('Q', QUARTER(h.hours_dateStart), '-', YEAR(h.hours_dateStart)) AS quarter,
    SUM(h.hours_worked) AS total_hours
FROM employee_hours h
JOIN employees e ON h.employee_id = e.employee_id
WHERE(YEAR(h.hours_dateStart) * 4 + QUARTER(h.hours_dateStart)) >=
    (YEAR(CURDATE() - INTERVAL 1 QUARTER) * 4 + QUARTER(CURDATE() - INTERVAL 1 QUARTER)) - 3
GROUP BY employee, quarter
ORDER BY employee, quarter;
"""
cursor.execute(query3)
rows = cursor.fetchall()

# Organize the data by employee
from collections import defaultdict

employee_data = defaultdict(list)
totals = defaultdict(int)

for employee, quarter, hours in rows:
    employee_data[employee].append((quarter, hours))
    totals[employee] += hours

# First table Show hours per quarter
print_header("Employee Hours by Quarter")
print_table(["Employee", "Quarter", "Hours Worked"], [
    (employee, quarter, hours)
    for employee, quarters in employee_data.items()
    for quarter, hours in quarters
])

# Second tabe Show total hours
print_header("Total Hours from Employee")
print_table(["Employee", "Total Hours Worked"], [
    (employee, totals[employee]) for employee in sorted(totals)
])

#CLEANUP
cursor.close()
conn.close()
print(" Report complete.")
