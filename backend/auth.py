from datetime import datetime, timedelta

from jose import JWTError, jwt

from backend.config import JWT_SECRET

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 7


def create_access_token(data: dict):

    payload = data.copy()

    payload["exp"] = (
        datetime.utcnow() +
        timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    )

    return jwt.encode(
        payload,
        JWT_SECRET,
        algorithm=ALGORITHM
    )


def verify_token(token: str):

    try:

        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[ALGORITHM]
        )

        return payload

    except JWTError:

        return None