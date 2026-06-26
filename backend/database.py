from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.engine.url import make_url
from dotenv import load_dotenv, find_dotenv
import os

# ---------------------------------------------------
# Load .env
# ---------------------------------------------------
dotenv_path = find_dotenv()

print("=" * 60)
print("DOTENV FILE =", dotenv_path)

load_dotenv(dotenv_path)

DATABASE_URL = os.getenv("DATABASE_URL")

print("DATABASE_URL =", DATABASE_URL)

# ---------------------------------------------------
# Parse URL (for debugging)
# ---------------------------------------------------
try:
    url = make_url(DATABASE_URL)

    print("-" * 60)
    print("Driver   :", url.drivername)
    print("Username :", url.username)
    print("Password :", url.password)
    print("Host     :", url.host)
    print("Port     :", url.port)
    print("Database :", url.database)
    print("-" * 60)

except Exception as e:
    print("URL PARSE ERROR:", e)

# ---------------------------------------------------
# Create SQLAlchemy Engine
# ---------------------------------------------------
engine = create_engine(
    DATABASE_URL,
    echo=True,          # Shows SQL statements
    pool_pre_ping=True  # Checks DB connection before use
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()