import requests
import config


def register(full_name, email, phone):

    r = requests.post(
        f"{config.BASE_URL}/register",
        json={
            "full_name": full_name,
            "email": email,
            "phone": phone
        },
        timeout=10
    )

    return r.json()


def send_login_otp(phone):

    r = requests.post(
        f"{config.BASE_URL}/send-login-otp",
        json={
            "phone": phone
        },
        timeout=10
    )

    return r.json()


def verify_otp(phone, otp):

    r = requests.post(
        f"{config.BASE_URL}/verify-otp",
        json={
            "phone": phone,
            "otp": otp
        },
        timeout=10
    )

    return r.json()


def resend_otp(phone):

    r = requests.post(
        f"{config.BASE_URL}/resend-otp",
        json={
            "phone": phone
        },
        timeout=10
    )

    return r.json()