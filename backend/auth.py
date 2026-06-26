from datetime import datetime, timedelta

from jose import JWTError, jwt

from backend.config import JWT_SECRET

print("=" * 60)
print("AUTH IMPORT")
print("JWT_SECRET =", repr(JWT_SECRET))
print("JWT_SECRET TYPE =", type(JWT_SECRET))
print("=" * 60)

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 7


def create_access_token(data: dict):

    payload = data.copy()

    payload["exp"] = (
        datetime.utcnow() +
        timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    )

    print("=" * 60)
    print("CREATE ACCESS TOKEN")
    print("PAYLOAD =", payload)
    print("JWT_SECRET =", repr(JWT_SECRET))
    print("JWT_SECRET TYPE =", type(JWT_SECRET))
    print("ALGORITHM =", ALGORITHM)
    print("=" * 60)

    token = jwt.encode(
        payload,
        JWT_SECRET,
        algorithm=ALGORITHM
    )

    print("TOKEN CREATED =", token)

    return token


def verify_token(token: str):

    try:

        print("=" * 60)
        print("VERIFY TOKEN")
        print("TOKEN =", token)
        print("JWT_SECRET =", repr(JWT_SECRET))
        print("=" * 60)

        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[ALGORITHM]
        )

        return payload

    except JWTError as e:

        print("JWT ERROR:", e)

        return None