#Team Members: Joel Atkinson, Zachary Baker, Kyle Klausen, Juan Macias Vasquez, Brittaney Perry-Morgan
# Date 07/13/2025
# Module 10.2 Group1 Winery Database
# Grouptables.py

import mysql.connector

# Connection configuration
config = {
    'user': 'wine_employee',
    'password': 'grapes', #Change to your own password
    'host': 'localhost'
}
 
def execute_sql_file(cursor, filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    statement = ''
    for line in lines:
        stripped = line.strip()

        if not stripped or stripped.startswith('--') or stripped.startswith('#'):
            continue

        statement += ' ' + stripped

        if stripped.endswith(';'):
            try:
                # Optional fix for subqueries with multiple results
                if "SELECT" in statement.upper() and "FROM" in statement.upper():
                    if "employee_id FROM employees WHERE employee_firstName" in statement:
                        # Auto-fix: add LIMIT 1 to subqueries that cause errors
                        statement = statement.replace("')", "' LIMIT 1)")  # crude but works here

                cursor.execute(statement)
            except mysql.connector.Error as err:
                print("Error executing SQL:")
                print(statement)
                print("MySQL Error:", err)
            statement = ''


def get_table_names(cursor):
    cursor.execute("SHOW TABLES")
    return [row[0] for row in cursor.fetchall()]

def get_primary_key(cursor, table):
    cursor.execute(f"SHOW KEYS FROM {table} WHERE Key_name = 'PRIMARY'")
    result = cursor.fetchone()
    return result[4] if result else None

def delete_duplicates(cursor, table, primary_key):
    cursor.execute(f"SHOW COLUMNS FROM {table}")
    columns = [row[0] for row in cursor.fetchall()]
    non_pk_columns = [col for col in columns if col != primary_key]

    if not non_pk_columns:
        return

    match_conditions = " AND ".join([f"t1.{col} = t2.{col}" for col in non_pk_columns])

    sql = f"""
        DELETE t1 FROM {table} t1
        INNER JOIN {table} t2
        WHERE t1.{primary_key} > t2.{primary_key}
          AND {match_conditions}
    """
    try:
        cursor.execute(sql)
    except mysql.connector.Error as err:
        print(f"Error deduplicating {table}: {err}")

def display_table(cursor, table):
    cursor.execute(f"SELECT * FROM {table}")
    rows = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]

    print(f"\n--- {table.upper()} ---")
    print(" | ".join(columns))
    print("-" * 60)
    for row in rows:
        print(" | ".join(str(val) for val in row))
    print(f"Total Rows: {len(rows)}")

def main():
    conn = None
    cursor = None
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()

        # Ensure database exists and select it
        cursor.execute("CREATE DATABASE IF NOT EXISTS Winery")
        cursor.execute("USE Winery")

        # Execute all SQL statements from file
        execute_sql_file(cursor, 'tables.sql')
        conn.commit()

        # Confirm use of Winery
        cursor.execute("USE Winery")

        # Deduplicate and show tables
        tables = get_table_names(cursor)
        for table in tables:
            pk = get_primary_key(cursor, table)
            if pk:
                delete_duplicates(cursor, table, pk)
                conn.commit()

        for table in tables:
            display_table(cursor, table)

    except mysql.connector.Error as err:
        print(f"Database error: {err}")
    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()

if __name__ == "__main__":
    main()
