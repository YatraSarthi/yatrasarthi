from datetime import datetime

from backend.schemas import (
    RegisterRequest,
    LoginOTPRequest,
    VerifyOTPRequest,
    ResendOTPRequest
)

from fastapi import APIRouter
from sqlalchemy.orm import Session

from backend.database import SessionLocal
from backend.models import User, OTPStore
from backend.otp import generate_otp
from backend.sms import send_sms
from backend.schemas import RegisterRequest
from backend.auth import create_access_token

router = APIRouter()


@router.get("/")
def root():

    return {
        "success": True,
        "message": "YatraSarthi Backend Running 🚖"
    }


@router.get("/health")
def health():

    return {
        "success": True,
        "status": "Healthy"
    }


@router.post("/register")
def register(request: RegisterRequest):

    db: Session = SessionLocal()

    try:

        existing_phone = (
            db.query(User)
            .filter(User.phone == request.phone)
            .first()
        )

        if existing_phone:

            return {
                "success": False,
                "message": "Phone number already registered."
            }

        existing_email = (
            db.query(User)
            .filter(User.email == request.email)
            .first()
        )

        if existing_email:

            return {
                "success": False,
                "message": "Email already registered."
            }

        otp = generate_otp()

        user = User(
            full_name=request.full_name,
            email=request.email,
            phone=request.phone,
            is_verified=0
        )

        db.add(user)

        db.flush()

        db.add(
            OTPStore(
                phone=request.phone,
                otp=otp,
                created_at=datetime.utcnow()
            )
        )

        db.commit()

        send_sms(
            request.phone,
            f"Your YatraSarthi OTP is {otp}"
        )

        return {
            "success": True,
            "message": "OTP sent successfully."
        }

    finally:

        db.close()
@router.post("/send-login-otp")
def send_login_otp(request: LoginOTPRequest):

    db: Session = SessionLocal()

    try:

        user = (
            db.query(User)
            .filter(User.phone == request.phone)
            .first()
        )

        if not user:

            return {
                "success": False,
                "message": "User not found."
            }

        db.query(OTPStore).filter(
            OTPStore.phone == request.phone
        ).delete()

        otp = generate_otp()

        db.add(
            OTPStore(
                phone=request.phone,
                otp=otp,
                created_at=datetime.utcnow()
            )
        )

        db.commit()

        send_sms(
            request.phone,
            f"Your YatraSarthi Login OTP is {otp}"
        )

        return {
            "success": True,
            "message": "OTP sent successfully."
        }

    finally:

        db.close()
@router.post("/verify-otp")
def verify_otp(request: VerifyOTPRequest):

    db: Session = SessionLocal()

    try:

        otp_record = (
            db.query(OTPStore)
            .filter(
                OTPStore.phone == request.phone,
                OTPStore.otp == request.otp
            )
            .first()
        )

        if not otp_record:

            return {
                "success": False,
                "message": "Invalid OTP."
            }

        user = (
            db.query(User)
            .filter(User.phone == request.phone)
            .first()
        )

        if not user:

            return {
                "success": False,
                "message": "User not found."
            }

        user.is_verified = 1

        db.delete(otp_record)

        db.commit()

        token = create_access_token(
            {
                "phone": user.phone
            }
        )

        return {
            "success": True,
            "message": "OTP verified.",
            "token": token
        }

    finally:

        db.close()
@router.post("/resend-otp")
def resend_otp(request: ResendOTPRequest):

    db: Session = SessionLocal()

    try:

        user = (
            db.query(User)
            .filter(User.phone == request.phone)
            .first()
        )

        if not user:

            return {
                "success": False,
                "message": "User not found."
            }

        db.query(OTPStore).filter(
            OTPStore.phone == request.phone
        ).delete()

        otp = generate_otp()

        db.add(
            OTPStore(
                phone=request.phone,
                otp=otp,
                created_at=datetime.utcnow()
            )
        )

        db.commit()

        send_sms(
            request.phone,
            f"Your new YatraSarthi OTP is {otp}"
        )

        return {
            "success": True,
            "message": "OTP resent successfully."
        }

    finally:

        db.close()