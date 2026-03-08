"""Authentication business logic"""
from sqlalchemy.orm import Session
from app.models.user import User
from app.utils.security import get_password_hash, verify_password

class AuthService:
    @staticmethod
    def create_user(db: Session, email: str, password: str, full_name: str, role: str):
        user = User(
            email=email,
            hashed_password=get_password_hash(password),
            full_name=full_name,
            role=role
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    def authenticate_user(db: Session, email: str, password: str):
        user = db.query(User).filter(User.email == email).first()
        if not user or not verify_password(password, user.hashed_password):
            return None
        return user