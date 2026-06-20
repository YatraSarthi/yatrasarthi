from fastapi import FastAPI
import requests
import math

from backend.sos import send_sos
from backend.database import engine
from backend.models import Base

print("===== THIS MAIN.PY IS RUNNING =====")

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("===== THIS MAIN.PY IS RUNNING =====")


# ----------------------------
# Home Endpoint
# ----------------------------
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

            display_name = data.get("display_name", "")

            if display_name:

                parts = [
                    part.strip()
                    for part in display_name.split(",")
                ]

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

    R = 6371

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

    cab_fare = round(80 + distance * 16)
    cab_eta = max(4, round(distance * 2))

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
            "fare": cab_fare,
            "eta": cab_eta
        },

        "carpool": {
            "fare": round(cab_fare * 0.6),
            "eta": cab_eta + 2,
            "availableSeats": 3,
            "routeMatch": 91,
            "co2Saved": 2.1
        }
}

# ----------------------------
# Route Preview
# ----------------------------
@app.get("/route")
def route(
    pickup_lat: float,
    pickup_lon: float,
    destination_lat: float,
    destination_lon: float
):

    url = (
        "https://router.project-osrm.org/route/v1/driving/"
        f"{pickup_lon},{pickup_lat};"
        f"{destination_lon},{destination_lat}"
        "?overview=full&geometries=geojson"
    )

    try:

        response = requests.get(url)

        if response.status_code == 200:
            return response.json()

    except Exception as e:
        print("Route Error:", e)

    return {
        "routes": []
    }

# ----------------------------
# Driver Location Simulation
# ----------------------------

driver_step = 0


@app.get("/driver-location")
def driver_location():

    global driver_step

    eta = max(1, 8 - driver_step)

    arrived = False

    if driver_step >= 8:
        arrived = True

    response = {
        "step": driver_step,
        "eta": eta,
        "arrived": arrived
    }

    if not arrived:
        driver_step += 1

    return response
# ----------------------------
# Reset Driver Simulation
# ----------------------------

@app.get("/reset-driver")
def reset_driver():

    global driver_step

    driver_step = 0

    return {
        "status": "reset"
    }

# ----------------------------
# SOS Endpoint
# ----------------------------
@app.get("/sos")
def sos():
    return send_sos()

Base.metadata.create_all(bind=engine)

print("Loaded main.py with SOS and Route endpoints")
