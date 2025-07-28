#Team Members: Joel Atkinson, Zachary Baker, Kyle Klausen, Juan Macias Vasquez, Brittaney Perry-Morgan
# Date 07/20/2025
# Module 11.1 Group1 Winery New Tables
# Main.py

import subprocess
import os

# Define script paths
group_tables_script = "GroupTables.py"
graphs_report_script = "GraphsReport.py"  # or use GraphsReport_NoDuplicates.py if desired

# Make sure the files exist
if not os.path.isfile(group_tables_script):
    print(f"Error: {group_tables_script} not found.")
elif not os.path.isfile(graphs_report_script):
    print(f"Error: {graphs_report_script} not found.")
else:
    # Run GroupTables.py but not showing output
    subprocess.run(["python", group_tables_script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # Then run GraphsReport.py wile showing output
    print("Running GraphsReport.py...")
    result = subprocess.run(["python", graphs_report_script], capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print("Errors from GraphsReport.py:", result.stderr)

    print("\nExecution complete.")
