from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func

from backend.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    email = Column(String, unique=True, nullable=False)

    name = Column(String, nullable=True)

    is_verified = Column(Boolean, default=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class OTPCode(Base):
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

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    sender = Column(
        String,
        nullable=False
    )

    receiver = Column(
        String,
        nullable=False
    )

    message = Column(
        String,
        nullable=False
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )