"""
Script to add 'specialization' column to student_profiles table
Run this script once to update the database schema
"""
import sys
sys.path.insert(0, '.')

from sqlalchemy import text
from app.database import engine

def add_specialization_column():
    """Add specialization column to student_profiles table"""
    with engine.connect() as conn:
        # Check if column already exists
        result = conn.execute(text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'student_profiles'
            AND column_name = 'specialization'
        """))

        if result.fetchone():
            print("Column 'specialization' already exists in student_profiles table")
            return

        # Add the column
        conn.execute(text("""
            ALTER TABLE student_profiles
            ADD COLUMN specialization VARCHAR(255)
        """))
        conn.commit()
        print("Successfully added 'specialization' column to student_profiles table")

if __name__ == "__main__":
    add_specialization_column()
