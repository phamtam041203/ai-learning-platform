#!/usr/bin/env python
"""Verify database schema"""
from sqlalchemy import create_engine, text, inspect
from app.config import Settings

print('🔍 Checking database schema...\n')
try:
    settings = Settings()
    engine = create_engine(settings.DATABASE_URL)
    inspector = inspect(engine)
    
    # Get columns from courses table
    columns = inspector.get_columns('courses')
    print(f'✅ Found {len(columns)} columns in courses table:\n')
    
    found_specialization = False
    for col in columns:
        name = col['name']
        if 'specialization' in name.lower():
            print(f'  ✓ {name} <- SPECIALIZATION COLUMN FOUND!')
            found_specialization = True
        else:
            print(f'  - {name}')
    
    if not found_specialization:
        print('\n❌ SPECIALIZATION COLUMN NOT FOUND!')
    else:
        print('\n✅ Database schema is correct!')
        
except Exception as e:
    print(f'❌ Error: {e}')
    import traceback
    traceback.print_exc()
