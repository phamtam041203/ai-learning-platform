#!/usr/bin/env python
"""Run Alembic migrations"""
import sys
from alembic.config import Config
from alembic import command

def main():
    try:
        cfg = Config('alembic.ini')
        command.upgrade(cfg, 'head')
        print("✓ Migration applied successfully")
        return 0
    except Exception as e:
        print(f"✗ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    sys.exit(main())
