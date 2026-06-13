from fastapi import FastAPI
import requests

app = FastAPI()


@app.get("/")
def home():
    return {"message": "YatraSarthi Backend Running"}


@app.get("/reverse-geocode")
def reverse_geocode(lat: float, lon: float):

    url = (
        f"https://nominatim.openstreetmap.org/reverse"
        f"?format=json&lat={lat}&lon={lon}"
    )

    headers = {
        "User-Agent": "YatraSarthi/1.0"
    }

    try:
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            data = response.json()

            return {
                "address": data.get(
                    "display_name",
                    f"{lat}, {lon}"
                )
            }

    except Exception as e:
        print(e)

    return {
        "address": f"{lat}, {lon}"
    }