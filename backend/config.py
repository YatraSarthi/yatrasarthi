from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

JWT_SECRET = os.getenv("JWT_SECRET")

SMSGATE_USERNAME = os.getenv("SMSGATE_USERNAME")

SMSGATE_PASSWORD = os.getenv("SMSGATE_PASSWORD")

SMSGATE_DEVICE_ID = os.getenv("SMSGATE_DEVICE_ID")