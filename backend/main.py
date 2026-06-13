from fastapi import FastAPI
import requests
import math

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

            address = data.get("address", {})

            short_address = (
                address.get("amenity")
                or address.get("building")
                or address.get("road")
                or address.get("suburb")
                or data.get("display_name")
            )

            return {
                "address": short_address
            }

    except Exception as e:
        print("Reverse geocoding error:", e)

    return {
        "address": f"{lat}, {lon}"
    }


@app.get("/estimate")
def estimate(
    pickup_lat: float,
    pickup_lon: float,
    destination_lat: float,
    destination_lon: float
):
    """
    Calculate distance and ride estimates
    """

    R = 6371  # Earth's radius in km

    dlat = math.radians(destination_lat - pickup_lat)
    dlon = math.radians(destination_lon - pickup_lon)

    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(pickup_lat))
        * math.cos(math.radians(destination_lat))
        * math.sin(dlon / 2) ** 2
    )

    c = 2 * math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a)
    )

    distance = R * c

    return {
        "distance": round(distance, 2),

        "bike": {
            "fare": round(30 + distance * 8),
            "eta": max(2, round(distance * 1.2))
        },

        "auto": {
            "fare": round(50 + distance * 12),
            "eta": max(4, round(distance * 1.5))
        },

        "cab": {
            "fare": round(80 + distance * 18),
            "eta": max(3, round(distance * 1.3))
        }
    }