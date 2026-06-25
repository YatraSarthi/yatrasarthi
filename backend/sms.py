import requests

from backend.config import (
    SMSGATE_USERNAME,
    SMSGATE_PASSWORD,
    SMSGATE_DEVICE_ID
)

TOKEN_URL = "https://api.sms-gate.app/3rdparty/v1/auth/token"

MESSAGE_URL = "https://api.sms-gate.app/3rdparty/v1/messages"


def get_token():

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

    print("STATUS:", response.status_code)
    print("BODY:", response.text)

    try:
        data = response.json()
        print("JSON:", data)
    except Exception as e:
        print("JSON ERROR:", e)
        return None

    if response.status_code != 201:
        return None

    return data["access_token"]


def send_sms(phone, message):

    phone = phone.strip()

    if not phone.startswith("+"):

        phone = "+91" + phone

    token = get_token()

    if token is None:

        return False

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
        }
    )

    print(response.text)

    return response.status_code in [
        200,
        201,
        202
    ]