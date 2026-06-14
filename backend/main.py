from fastapi import FastAPI
import requests
import math

from backend.sos import send_sos

print("===== THIS MAIN.PY IS RUNNING =====")

app = FastAPI()


@app.get("/")
def home():
    return {
        "message": "YatraSarthi Backend Running"
    }


# ----------------------------
# Reverse Geocoding
# ----------------------------
@app.get("/reverse-geocode")
def reverse_geocode(lat: float, lon: float):

    url = (
        f"https://nominatim.openstreetmap.org/reverse"
        f"?format=json"
        f"&lat={lat}"
        f"&lon={lon}"
        f"&zoom=18"
        f"&addressdetails=1"
    )

    headers = {
        "User-Agent": "YatraSarthi/1.0"
    }

    try:
        response = requests.get(url, headers=headers)

        if response.status_code == 200:

            data = response.json()

            # Full address from Nominatim
            display_name = data.get("display_name", "")

            if display_name:

                parts = [
                    part.strip()
                    for part in display_name.split(",")
                ]

                # First 3 parts for UI display
                short_address = ", ".join(parts[:3])

            else:
                short_address = f"{lat}, {lon}"

            return {
                "address": short_address,
                "full_address": display_name
            }

    except Exception as e:
        print("Reverse geocoding error:", e)

    return {
        "address": f"{lat}, {lon}",
        "full_address": f"{lat}, {lon}"
    }


# ----------------------------
# Fare Estimation
# ----------------------------
@app.get("/estimate")
def estimate(
    pickup_lat: float,
    pickup_lon: float,
    destination_lat: float,
    destination_lon: float
):

    R = 6371  # Earth's radius in km

    lat1 = math.radians(pickup_lat)
    lon1 = math.radians(pickup_lon)

    lat2 = math.radians(destination_lat)
    lon2 = math.radians(destination_lon)

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(lat1)
        * math.cos(lat2)
        * math.sin(dlon / 2) ** 2
    )

    c = 2 * math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a)
    )

    distance = round(R * c, 2)

    return {
        "distance": distance,

        "bike": {
            "fare": round(25 + distance * 8),
            "eta": max(2, round(distance * 2))
        },

        "auto": {
            "fare": round(40 + distance * 12),
            "eta": max(3, round(distance * 2.5))
        },

        "cab": {
            "fare": round(80 + distance * 16),
            "eta": max(4, round(distance * 2))
        }
    }


# ----------------------------
# SOS Endpoint
# ----------------------------
@app.get("/sos")
def sos():
    return send_sos()


print("Loaded main.py with SOS endpoint")
