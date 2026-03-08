"""
Security utilities:
- Password hashing (bcrypt, Unicode-safe)
- JWT access token
- Authentication dependency
"""

from datetime import datetime, timedelta
from typing import Optional, Dict

from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from passlib.context import CryptContext
from jose import JWTError, jwt
from app.core.config import settings

# ======================================================
# Password hashing (bcrypt)
# ======================================================
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


def get_password_hash(password: str) -> str:
    """
    Hash a plain password (bcrypt limit: 72 chars)
    """
    # Truncate to 72 characters (bcrypt limit)
    if len(password) > 72:
        password = password[:72]
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify plain password against hashed password
    """
    # Truncate to 72 characters (bcrypt limit)
    if len(plain_password) > 72:
        plain_password = plain_password[:72]
    return pwd_context.verify(plain_password, hashed_password)


# ======================================================
# JWT configuration
# ======================================================
# Use shared settings for JWT
SECRET_KEY = settings.SECRET_KEY
ALGORITHM = settings.ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES = settings.ACCESS_TOKEN_EXPIRE_MINUTES

# ======================================================
# JWT helpers
# ======================================================
def create_access_token(
    data: Dict,
    expires_delta: Optional[timedelta] = None,
) -> str:
    """
    Create JWT access token
    """
    to_encode = data.copy()

    expire = (
        datetime.utcnow() + expires_delta
        if expires_delta
        else datetime.utcnow()
        + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    to_encode.update({"exp": expire})

    return jwt.encode(
        to_encode,
        SECRET_KEY,
        algorithm=ALGORITHM,
    )


def decode_access_token(token: str) -> Dict:
    """
    Decode and validate JWT token
    """
    try:
        return jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )


# ======================================================
# FastAPI dependency: current user
# ======================================================
security = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> Dict:
    """
    Get current user from Authorization: Bearer <token>
    """
    token = credentials.credentials
    payload = decode_access_token(token)

    if "sub" not in payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )

    return payload


# ======================================================
# Token revoke (OPTIONAL – future use)
# ======================================================
def revoke_token(token: str):
    """
    Revoke token (blacklist)
    TODO: Implement with Redis or database
    """
    pass


def is_token_revoked(token: str) -> bool:
    """
    Check if token is revoked
    TODO: Implement with Redis or database
    """
    return False