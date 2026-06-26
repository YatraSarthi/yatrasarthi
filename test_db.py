import psycopg2

try:
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="yatrasarthi",
        user="yatra_user",
        password="1234"
    )

    print("SUCCESS")
    conn.close()

except Exception as e:
    print(e)
