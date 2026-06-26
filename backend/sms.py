import requests

from backend.config import (
    SMSGATE_USERNAME,
    SMSGATE_PASSWORD,
    SMSGATE_DEVICE_ID
)

TOKEN_URL = "https://api.sms-gate.app/3rdparty/v1/auth/token"
MESSAGE_URL = "https://api.sms-gate.app/3rdparty/v1/messages"


def get_token():

    try:

        response = requests.post(
            TOKEN_URL,
            auth=(
                SMSGATE_USERNAME,
                SMSGATE_PASSWORD
            ),
            json={
                "scopes": [
                    "messages:send",
                    "devices:list"
                ],
                "ttl": 0
            },
            timeout=10
        )

        print("=" * 60)
        print("TOKEN STATUS:", response.status_code)
        print("TOKEN BODY:", response.text)
        print("=" * 60)

        if response.status_code != 201:
            return None

        return response.json()["access_token"]

    except Exception as e:

        print("TOKEN ERROR:", e)

        return None


def send_sms(phone, message):

    phone = phone.strip()

    if not phone.startswith("+"):
        phone = "+91" + phone

    token = get_token()

    if token is None:

        print("SMS TOKEN FAILED")

        # Don't block login
        return True

    try:

        response = requests.post(
            MESSAGE_URL,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            json={
                "deviceId": SMSGATE_DEVICE_ID,
                "message": message,
                "phoneNumbers": [
                    phone
                ]
            },
            timeout=10
        )

        print("=" * 60)
        print("SMS STATUS:", response.status_code)
        print("SMS BODY:", response.text)
        print("=" * 60)

        return response.status_code in [200, 201, 202]

    except Exception as e:

        print("SMS ERROR:", e)

        return True