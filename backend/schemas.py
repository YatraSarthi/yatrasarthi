from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):

    full_name: str

    email: EmailStr

    phone: str


class LoginOTPRequest(BaseModel):

    phone: str


class VerifyOTPRequest(BaseModel):

    phone: str

    otp: str


class ResendOTPRequest(BaseModel):

    phone: str


class TokenResponse(BaseModel):

    success: bool

    message: str

    token: str | None = None