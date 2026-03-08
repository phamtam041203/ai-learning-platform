import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.database import SessionLocal
from app.models.user import User, UserRole
from app.utils.security import get_password_hash


def main() -> None:
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == "admin").first()
        if user:
            print("ADMIN_EXISTS", user.id, user.email, user.role, user.is_active)
            return

        admin = User(
            email="admin",
            hashed_password=get_password_hash("admin"),
            full_name="Administrator",
            role=UserRole.ADMIN,
            is_active=True
        )
        db.add(admin)
        db.commit()
        db.refresh(admin)
        print("ADMIN_CREATED", admin.id, admin.email, admin.role, admin.is_active)
    finally:
        db.close()


if __name__ == "__main__":
    main()
