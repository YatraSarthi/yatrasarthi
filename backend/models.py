from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func

from backend.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    full_name = Column(String, nullable=True)

    email = Column(String, unique=True, nullable=False)

    phone = Column(String, unique=True, nullable=True)

    name = Column(String, nullable=True)          # legacy column — kept for compat

    is_verified = Column(Boolean, default=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class OTPStore(Base):
    """Stores OTPs keyed by phone number (one active OTP per phone)."""
    __tablename__ = "otp_store"

    id = Column(Integer, primary_key=True, index=True)

    phone = Column(String, nullable=False, index=True)

    otp = Column(String(6), nullable=False)

    created_at = Column(DateTime(timezone=True), nullable=True)


class OTPCode(Base):
    """Legacy email-based OTP table — kept so existing DB migrations don't break."""
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, index=True)

    email = Column(String, nullable=False)

    otp = Column(String(6), nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)

    sender = Column(String, nullable=False)

    receiver = Column(String, nullable=False)

    message = Column(String, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )