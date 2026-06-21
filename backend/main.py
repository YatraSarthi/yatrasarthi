from fastapi import FastAPI
import requests
import math
import random
import json
import os
from backend.sos import send_sos
from backend.database import engine
from backend.models import Base

print("===== THIS MAIN.PY IS RUNNING =====")

app = FastAPI()

search_cache = {}

RECENT_FILE = "recent_places.json"

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
        "User-Agent":
        "YatraSarthi/1.0 (contact@yatrasarthi.com)"
    }

    try:

        response = requests.get(
            url,
            headers=headers,
            timeout=10
        )

        print(
            "Reverse Status:",
            response.status_code
        )

        print(
            "Reverse Response:",
            response.text[:300]
        )

        if response.status_code == 200:

            data = response.json()

            display_name = data.get(
                "display_name",
                ""
            )

            if display_name:

                parts = [
                    part.strip()
                    for part in display_name.split(",")
                ]

                short_address = ", ".join(
                    parts[:3]
                )

                return {
                    "address":
                        short_address,
                    "full_address":
                        display_name
                }

    except Exception as e:

        print(
            "Reverse Geocode Error:",
            e
        )

    return {
        "address":
            f"{lat},{lon}",
        "full_address":
            f"{lat},{lon}"
    }


# ----------------------------
# Location Search
# ----------------------------
@app.get("/search-location")
def search_location(query: str):

    global search_cache

    if query in search_cache:
        return search_cache[query]

    url = (
        "https://nominatim.openstreetmap.org/search"
        f"?q={query}"
        "&format=jsonv2"
        "&limit=5"
    )

    headers = {
        "User-Agent":
        "YatraSarthi Hackathon Project"
    }

    try:

        response = requests.get(
            url,
            headers=headers,
            timeout=10
        )

        if response.status_code == 200:

            results = response.json()

            places = []

            for place in results:

                places.append({
                    "name":
                        place["display_name"],
                    "display_name":
                        place["display_name"],
                    "lat":
                        float(place["lat"]),
                    "lon":
                        float(place["lon"])
                })

            search_cache[query] = places

            return places

        print(
            "Search Status:",
            response.status_code
        )

    except Exception as e:

        print(
            "Search Error:",
            e
        )

    return []


# ----------------------------
# Recent Places
# ----------------------------
@app.get("/recent-places")
def get_recent_places():

    if not os.path.exists(RECENT_FILE):
        return []

    try:

        with open(RECENT_FILE, "r") as f:
            return json.load(f)

    except Exception as e:

        print("Recent Places Read Error:", e)
        return []


@app.post("/recent-places")
def save_recent_place(
    name: str,
    lat: float,
    lon: float
):

    try:

        places = []

        if os.path.exists(RECENT_FILE):

            with open(RECENT_FILE, "r") as f:
                places = json.load(f)

        # Remove duplicate entry if same name exists
        places = [
            p for p in places
            if p["name"] != name
        ]

        # Insert new entry at the top
        places.insert(0, {
            "name": name,
            "lat": lat,
            "lon": lon
        })

        # Keep only the 5 most recent
        places = places[:5]

        with open(RECENT_FILE, "w") as f:
            json.dump(places, f, indent=2)

        return {"status": "ok"}

    except Exception as e:

        print("Recent Places Write Error:", e)
        return {"status": "error", "detail": str(e)}


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
# Driver Simulation
# ----------------------------

driver_step = 0

driver_lat = 0
driver_lon = 0

pickup_lat_global = 0
pickup_lon_global = 0

driver_eta = 0
driver_distance = 0


@app.get("/start-driver")
def start_driver(
    pickup_lat: float,
    pickup_lon: float
):

    global driver_step
    global driver_lat
    global driver_lon

    global pickup_lat_global
    global pickup_lon_global

    global driver_eta
    global driver_distance

    driver_step = 0

    pickup_lat_global = pickup_lat
    pickup_lon_global = pickup_lon

    # Random location near pickup
    offset_lat = random.uniform(
        0.003,
        0.015
    )

    offset_lon = random.uniform(
        0.003,
        0.015
    )

    driver_lat = (
        pickup_lat +
        random.choice([-1, 1])
        * offset_lat
    )

    driver_lon = (
        pickup_lon +
        random.choice([-1, 1])
        * offset_lon
    )

    # Random ETA
    driver_eta = random.randint(
        3,
        8
    )

    # Approx distance
    driver_distance = round(
        math.sqrt(
            offset_lat**2 +
            offset_lon**2
        ) * 111,
        1
    )

    return {

        "driverLat": driver_lat,
        "driverLon": driver_lon,

        "distance": driver_distance,
        "eta": driver_eta,

        "driverName": "Agnik Haldar",
        "vehicleNumber": "WB03AD7394",
        "driverRating": 4.8
    }


@app.get("/driver-location")
def driver_location():

    global driver_step

    global driver_lat
    global driver_lon

    global pickup_lat_global
    global pickup_lon_global

    global driver_distance
    global driver_eta

    arrived = False

    if driver_step >= 15:

        arrived = True

        driver_lat = pickup_lat_global
        driver_lon = pickup_lon_global

        driver_distance = 0

    else:

        driver_lat += (
            pickup_lat_global
            - driver_lat
        ) / 15

        driver_lon += (
            pickup_lon_global
            - driver_lon
        ) / 15

        driver_distance = round(
            math.sqrt(
                (pickup_lat_global - driver_lat) ** 2 +
                (pickup_lon_global - driver_lon) ** 2
            ) * 111,
            1
        )

        driver_step += 1

    return {

        "driverLat": driver_lat,
        "driverLon": driver_lon,

        "distance": driver_distance,

        "eta": max(
            1,
            round(driver_distance * 2)
        ),

        "arrived": arrived
    }


# ----------------------------
# Pickup Route
# ----------------------------
@app.get("/pickup-route")
def pickup_route(
    driver_lat: float,
    driver_lon: float,
    pickup_lat: float,
    pickup_lon: float
):

    url = (
        "https://router.project-osrm.org/route/v1/driving/"
        f"{driver_lon},{driver_lat};"
        f"{pickup_lon},{pickup_lat}"
        "?overview=full&geometries=geojson"
    )

    try:

        response = requests.get(url)

        if response.status_code == 200:
            return response.json()

    except Exception as e:

        print(
            "Pickup Route Error:",
            e
        )

    return {
        "routes": []
    }


# ----------------------------
# SOS Endpoint
# ----------------------------
@app.get("/sos")
def sos():
    return send_sos()


Base.metadata.create_all(bind=engine)

print("Loaded main.py with SOS and Route endpoints")