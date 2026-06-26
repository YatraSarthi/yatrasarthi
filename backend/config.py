from dotenv import load_dotenv, find_dotenv
import os

dotenv_path = find_dotenv()

print("CONFIG DOTENV =", dotenv_path)

load_dotenv(dotenv_path)

DATABASE_URL = os.getenv("DATABASE_URL")
JWT_SECRET = os.getenv("JWT_SECRET")

print("DATABASE_URL =", DATABASE_URL)
print("JWT_SECRET =", repr(JWT_SECRET))

SMSGATE_USERNAME = os.getenv("SMSGATE_USERNAME")
SMSGATE_PASSWORD = os.getenv("SMSGATE_PASSWORD")
SMSGATE_DEVICE_ID = os.getenv("SMSGATE_DEVICE_ID")