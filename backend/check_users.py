"""
Check existing users
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models import User

db = SessionLocal()
try:
    users = db.query(User).all()
    print(f"📋 Found {len(users)} users:\n")
    for user in users:
        print(f"  Email: {user.email}")
        print(f"  Role: {user.role}")
        print(f"  ID: {user.id}")
        print()
finally:
    db.close()
