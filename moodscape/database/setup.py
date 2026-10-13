"""
MoodScape Database Setup Script
Creates database and tables for the mood-based movie review platform
Academic Project for CSE370 (Database Systems)
"""

import mysql.connector
from mysql.connector import Error
import sys

def create_database_and_tables():
    """Create database and execute SQL schema"""
    
    # Database configuration (update with your MySQL credentials)
    config = {
        'host': 'localhost',
        'user': 'root',
        'password': '',  # Enter your MySQL password here
        'port': 3306
    }
    
    try:
        # Connect to MySQL server (without database)
        connection = mysql.connector.connect(**config)
        cursor = connection.cursor()
        
        print("Connected to MySQL server successfully!")
        
        # Create database if it doesn't exist
        cursor.execute("CREATE DATABASE IF NOT EXISTS moodscape_db")
        print("Database 'moodscape_db' created or already exists.")
        
        # Use the database
        cursor.execute("USE moodscape_db")
        
        # Read and execute schema
        with open('schema.sql', 'r') as f:
            schema_sql = f.read()
        
        # Split SQL commands and execute
        commands = schema_sql.split(';')
        for command in commands:
            command = command.strip()
            if command and not command.startswith('--') and not command.startswith('/*'):
                try:
                    cursor.execute(command)
                except Error as e:
                    print(f"Warning: {e}")
                    continue
        
        print("Database schema created successfully!")
        
        # Execute sample data
        with open('sample_data.sql', 'r') as f:
            sample_data_sql = f.read()
        
        # Split SQL commands and execute
        commands = sample_data_sql.split(';')
        for command in commands:
            command = command.strip()
            if command and not command.startswith('--') and not command.startswith('/*'):
                try:
                    cursor.execute(command)
                except Error as e:
                    print(f"Warning inserting sample data: {e}")
                    continue
        
        connection.commit()
        print("Sample data inserted successfully!")
        
        cursor.close()
        connection.close()
        
        print("\nDatabase setup completed successfully!")
        print("You can now run the Flask application.")
        
    except Error as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    print("MoodScape Database Setup")
    print("=" * 50)
    print("This script will create the database and tables for MoodScape.")
    print("Make sure MySQL is running and update the connection settings.")
    print("=" * 50)
    
    response = input("Continue? (y/n): ")
    if response.lower() == 'y':
        create_database_and_tables()
    else:
        print("Setup cancelled.")