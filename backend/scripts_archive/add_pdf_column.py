"""
Add pdf_file_name column to lessons table
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import engine
from sqlalchemy import text

def add_pdf_file_name_column():
    try:
        with engine.connect() as conn:
            # Check if column exists
            result = conn.execute(text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='lessons' AND column_name='pdf_file_name'
            """))
            
            if result.fetchone():
                print("✅ Column pdf_file_name already exists")
                return
            
            # Add column
            conn.execute(text("""
                ALTER TABLE lessons 
                ADD COLUMN pdf_file_name VARCHAR(500)
            """))
            conn.commit()
            
            print("✅ Successfully added pdf_file_name column to lessons table")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    add_pdf_file_name_column()
