from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import requests
import math
import random
import json
import os
from backend.sos import send_sos
from backend.database import engine, SessionLocal
from backend.models import Base, Message

print("===== THIS MAIN.PY IS RUNNING =====")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/web", StaticFiles(directory="app/web"), name="web")

search_cache = {}
RECENT_FILE = "recent_places.json"
SOS_INFO_FILE = "sos_info.json"

# Pool of driver names/vehicles — rotated on retry so UI name changes too
# Photo filenames match EXACTLY what is in assets/image/ folder (case-sensitive
# on Linux/WSL — confirmed via `ls -la assets/image/`):
#   agnik.jpeg, Devaj.jpeg, Ibrahim.jpeg, Johney.jpeg, Lokesh.jpeg,
#   Manu.jpeg, Satyakam.jpeg
DRIVER_POOL = [
    {
        "name": "Johney Reji",
        "vehicle": "WB03AD7394",
        "vehicleModel": "Honda SP125",
        "rating": 4.4,
        "photo": "Johney.jpeg"
    },
    {
        "name": "Lokesh Royal",
        "vehicle": "KA01AB1234",
        "vehicleModel": "Bajaj RE Auto",
        "rating": 4.7,
        "photo": "Lokesh.jpeg"
    },
    {
        "name": "Satyakam Tripathy",
        "vehicle": "KA02CD5678",
        "vehicleModel": "Maruti Suzuki Dzire",
        "rating": 4.7,
        "photo": "Satyakam.jpeg"
    },
    {
        "name": "Devaj",
        "vehicle": "KA03EF9012",
        "vehicleModel": "Mitsubishi Pajero",
        "rating": 4.6,
        "photo": "Devaj.jpeg"
    },
    {
        "name": "Ibrahim",
        "vehicle": "KA04GH3456",
        "vehicleModel": "Maruti Suzuki Ertiga",
        "rating": 4.5,
        "photo": "Ibrahim.jpeg"
    },
    {
        "name": "Manaswitha",
        "vehicle": "KA05IJ7890",
        "vehicleModel": "Toyota Innova Crysta",
        "rating": 4.9,
        "photo": "Manu.jpeg"
    },
    {
        "name": "Agnik",
        "vehicle": "KA06KL2345",
        "vehicleModel": "Hyundai Grand i10",
        "rating": 4.3,
        "photo": "agnik.jpeg"          # lowercase 'a' — matches actual filename
    },
]

# ----------------------------
# Home Endpoint
# ----------------------------


@app.get("/")
def home():
    return {"message": "YatraSarthi Backend Running"}


# ----------------------------
# Reverse Geocoding
# ----------------------------
@app.get("/reverse-geocode")
def reverse_geocode(lat: float, lon: float):
    url = (
        f"https://nominatim.openstreetmap.org/reverse"
        f"?format=json&lat={lat}&lon={lon}&zoom=18&addressdetails=1"
    )
    headers = {"User-Agent": "YatraSarthi/1.0 (contact@yatrasarthi.com)"}
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            display_name = data.get("display_name", "")
            if display_name:
                parts = [p.strip() for p in display_name.split(",")]
                short_address = ", ".join(parts[:3])
                return {"address": short_address, "full_address": display_name}
    except Exception as e:
        print("Reverse Geocode Error:", e)
    return {"address": f"{lat},{lon}", "full_address": f"{lat},{lon}"}


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
        f"?q={query}&format=jsonv2&limit=5"
    )
    headers = {"User-Agent": "YatraSarthi Hackathon Project"}
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            results = response.json()
            places = []
            for place in results:
                places.append({
                    "name": place["display_name"],
                    "display_name": place["display_name"],
                    "lat": float(place["lat"]),
                    "lon": float(place["lon"])
                })
            search_cache[query] = places
            return places
    except Exception as e:
        print("Search Error:", e)
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
def save_recent_place(name: str, lat: float, lon: float):
    try:
        places = []
        if os.path.exists(RECENT_FILE):
            with open(RECENT_FILE, "r") as f:
                places = json.load(f)
        places = [p for p in places if p["name"] != name]
        places.insert(0, {"name": name, "lat": lat, "lon": lon})
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
    pickup_lat: float, pickup_lon: float,
    destination_lat: float, destination_lon: float
):
    R = 6371
    lat1, lon1 = math.radians(pickup_lat), math.radians(pickup_lon)
    lat2, lon2 = math.radians(destination_lat), math.radians(destination_lon)
    dlat, dlon = lat2 - lat1, lon2 - lon1
    a = (math.sin(dlat/2)**2 + math.cos(lat1)
         * math.cos(lat2)*math.sin(dlon/2)**2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    distance = round(R * c, 2)
    cab_fare = round(80 + distance * 16)
    cab_eta = max(4, round(distance * 2))
    return {
        "distance": distance,
        "bike":    {"fare": round(25 + distance * 8),  "eta": max(2, round(distance * 2))},
        "auto":    {"fare": round(40 + distance * 12), "eta": max(3, round(distance * 2.5))},
        "cab":     {"fare": cab_fare, "eta": cab_eta},
        "carpool": {
            "fare": round(cab_fare * 0.6), "eta": cab_eta + 2,
            "availableSeats": 3, "routeMatch": 91, "co2Saved": 2.1
        }
    }


# ----------------------------
# Route Preview
# ----------------------------
@app.get("/route")
def route(
    pickup_lat: float, pickup_lon: float,
    destination_lat: float, destination_lon: float
):
    url = (
        "https://router.project-osrm.org/route/v1/driving/"
        f"{pickup_lon},{pickup_lat};{destination_lon},{destination_lat}"
        "?overview=full&geometries=geojson"
    )
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return response.json()
    except Exception as e:
        print("Route Error:", e)
    return {"routes": []}


# ----------------------------
# Driver Simulation
# ----------------------------
driver_step = 0
driver_lat = 0.0
driver_lon = 0.0
pickup_lat_global = 0.0
pickup_lon_global = 0.0
driver_eta = 0
driver_distance = 0.0
driver_pool_index = 0   # advances on each /reset-driver so name changes


@app.get("/start-driver")
def start_driver(pickup_lat: float, pickup_lon: float, selected_vehicle: str = "cab"):
    global driver_step, driver_lat, driver_lon
    global pickup_lat_global, pickup_lon_global
    global driver_eta, driver_distance, driver_pool_index

    driver_step = 0
    pickup_lat_global = pickup_lat
    pickup_lon_global = pickup_lon

    offset_lat = random.uniform(0.008, 0.018)
    offset_lon = random.uniform(0.008, 0.018)
    driver_lat = pickup_lat + random.choice([-1, 1]) * offset_lat
    driver_lon = pickup_lon + random.choice([-1, 1]) * offset_lon
    driver_eta = random.randint(3, 9)
    driver_distance = round(math.sqrt(offset_lat**2 + offset_lon**2) * 111, 1)

    # Pick driver profile from pool (copy so we don't mutate the original)
    profile = dict(DRIVER_POOL[driver_pool_index % len(DRIVER_POOL)])

    vehicle_type = selected_vehicle.lower()

    VEHICLE_MODELS = {
        "bike": [
            "Honda SP125",
            "TVS Raider",
            "Bajaj Pulsar 150",
            "Hero Splendor Plus",
            "TVS Apache RTR 160",
            "Honda Shine",
            "Yamaha FZ-S"
        ],
        "auto": [
            "Bajaj RE Auto",
            "Piaggio Ape City",
            "Mahindra Alfa Auto",
            "Atul Gem Auto",
            "Mahindra Treo EV",
            "Bajaj Compact RE",
            "TVS King Deluxe"
        ],
        "cab": [
            "Maruti Suzuki Dzire",
            "Hyundai Aura",
            "Honda Amaze",
            "Toyota Etios",
            "Maruti WagonR",
            "Hyundai Grand i10",
            "Tata Tigor"
        ],
        "carpool": [
            "Toyota Innova Crysta",
            "Maruti Suzuki Ertiga",
            "Toyota Rumion",
            "Kia Carens",
            "Hyundai Creta",
            "Mahindra XUV700",
            "MG Hector Plus"
        ],
    }

    # Each driver index gets the matching model from their vehicle category
    models = VEHICLE_MODELS.get(vehicle_type, VEHICLE_MODELS["cab"])
    profile["vehicleModel"] = models[driver_pool_index % len(models)]

    return {
        "driverLat":    driver_lat,
        "driverLon":    driver_lon,
        "distance":     driver_distance,
        "eta":          driver_eta,
        "driverName":   profile["name"],
        "vehicleNumber": profile["vehicle"],
        "vehicleModel": profile["vehicleModel"],
        "driverRating": profile["rating"],
        "driverPhoto":  profile["photo"]   # e.g. "Johney.jpeg", "agnik.jpeg" …
    }


@app.get("/driver-location")
def driver_location():
    global driver_step, driver_lat, driver_lon
    global pickup_lat_global, pickup_lon_global
    global driver_distance, driver_eta

    arrived = False
    if driver_step >= 15:
        arrived = True
        driver_lat = pickup_lat_global
        driver_lon = pickup_lon_global
        driver_distance = 0
    else:
        driver_lat += (pickup_lat_global - driver_lat) / 15
        driver_lon += (pickup_lon_global - driver_lon) / 15
        driver_distance = round(
            math.sqrt(
                (pickup_lat_global - driver_lat)**2 +
                (pickup_lon_global - driver_lon)**2
            ) * 111, 1
        )
        driver_step += 1

    return {
        "driverLat": driver_lat, "driverLon": driver_lon,
        "distance":  driver_distance,
        "eta":       max(1, round(driver_distance * 2)),
        "arrived":   arrived
    }


@app.get("/reset-driver")
def reset_driver():
    global driver_step, driver_distance, driver_pool_index
    driver_step = 0
    driver_distance = 0
    driver_pool_index += 1   # advance pool so next /start-driver returns new name
    return {"message": "Driver reset", "nextDriverIndex": driver_pool_index}


# ----------------------------
# Pickup Route
# ----------------------------
@app.get("/pickup-route")
def pickup_route(
    driver_lat: float, driver_lon: float,
    pickup_lat: float, pickup_lon: float
):
    url = (
        "https://router.project-osrm.org/route/v1/driving/"
        f"{driver_lon},{driver_lat};{pickup_lon},{pickup_lat}"
        "?overview=full&geometries=geojson"
    )
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return response.json()
    except Exception as e:
        print("Pickup Route Error:", e)
    return {"routes": []}


# ----------------------------
# SOS
# ----------------------------
@app.get("/sos")
def sos():
    return send_sos()


# ----------------------------
# SOS Info
# ----------------------------
@app.get("/sos/info")
def get_sos_info():
    if not os.path.exists(SOS_INFO_FILE):
        return {
            "contact1Name": "", "contact1Phone": "",
            "contact2Name": "", "contact2Phone": "",
            "bloodGroup": "", "medicalNotes": ""
        }
    try:
        with open(SOS_INFO_FILE, "r") as f:
            return json.load(f)
    except Exception as e:
        print("SOS Info Read Error:", e)
        return {
            "contact1Name": "", "contact1Phone": "",
            "contact2Name": "", "contact2Phone": "",
            "bloodGroup": "", "medicalNotes": ""
        }


@app.post("/sos/info")
def save_sos_info(
    contact1Name: str = "", contact1Phone: str = "",
    contact2Name: str = "", contact2Phone: str = "",
    bloodGroup: str = "", medicalNotes: str = ""
):
    try:
        data = {
            "contact1Name": contact1Name, "contact1Phone": contact1Phone,
            "contact2Name": contact2Name, "contact2Phone": contact2Phone,
            "bloodGroup": bloodGroup, "medicalNotes": medicalNotes
        }
        with open(SOS_INFO_FILE, "w") as f:
            json.dump(data, f, indent=2)
        return {"status": "ok"}
    except Exception as e:
        print("SOS Info Write Error:", e)
        return {"status": "error", "detail": str(e)}


# ----------------------------
# Favourites
# ----------------------------
favourites_store = [
    {"label": "Home", "emoji": "🏠", "color": "#E3F2FD",
        "name": "", "lat": 0, "lon": 0},
    {"label": "Work", "emoji": "💼", "color": "#FFF3E0", "name": "", "lat": 0, "lon": 0}
]


@app.get("/favourites")
def get_favourites():
    return favourites_store


# ----------------------------
# Ride History
# ----------------------------
ride_history_store = []


@app.get("/ride-history")
def get_ride_history():
    return ride_history_store


@app.post("/ride-history")
def add_ride_history(
    pickup: str, destination: str, vehicle: str,
    fare: float, distance: float, co2_saved: float
):
    ride_history_store.append({
        "date": "Today", "pickup": pickup, "destination": destination,
        "vehicle": vehicle, "fare": fare, "distance": distance, "co2Saved": co2_saved
    })
    return {"status": "ok"}


# ----------------------------
# Ride In Progress
# ----------------------------
ride_route_coords = []
ride_step = 0
ride_total_steps = 0
ride_dest_lat = 0.0
ride_dest_lon = 0.0
ride_pickup_lat_g = 0.0
ride_pickup_lon_g = 0.0


@app.get("/start-ride")
def start_ride(
    pickup_lat: float, pickup_lon: float,
    destination_lat: float, destination_lon: float
):
    global ride_route_coords, ride_step, ride_total_steps
    global ride_dest_lat, ride_dest_lon
    global ride_pickup_lat_g, ride_pickup_lon_g

    ride_pickup_lat_g = pickup_lat
    ride_pickup_lon_g = pickup_lon
    ride_dest_lat = destination_lat
    ride_dest_lon = destination_lon
    ride_step = 0

    try:
        url = (
            "https://router.project-osrm.org/route/v1/driving/"
            f"{pickup_lon},{pickup_lat};{destination_lon},{destination_lat}"
            "?overview=full&geometries=geojson"
        )
        resp = requests.get(url, timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            coords = data["routes"][0]["geometry"]["coordinates"]
            ride_route_coords = [[c[1], c[0]] for c in coords]
        else:
            ride_route_coords = []
    except Exception as e:
        print("start-ride route error:", e)
        ride_route_coords = []

    ride_total_steps = max(len(ride_route_coords) - 1, 1)

    R = 6371
    lat1, lon1 = math.radians(pickup_lat), math.radians(pickup_lon)
    lat2, lon2 = math.radians(destination_lat), math.radians(destination_lon)
    dlat, dlon = lat2 - lat1, lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
    distance = round(R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)), 2)
    eta = max(2, round(distance * 2))

    veh_lat = ride_route_coords[0][0] if ride_route_coords else pickup_lat
    veh_lon = ride_route_coords[0][1] if ride_route_coords else pickup_lon

    return {
        "vehicleLat": veh_lat, "vehicleLon": veh_lon,
        "distance": distance, "eta": eta,
        "speed": random.randint(25, 35)
    }


@app.get("/ride-location")
def ride_location():
    global ride_step, ride_route_coords

    if not ride_route_coords:
        return {
            "vehicleLat": ride_pickup_lat_g, "vehicleLon": ride_pickup_lon_g,
            "distance": 0, "eta": 0, "speed": 0, "completed": True
        }

    ride_step = min(ride_step + 2, len(ride_route_coords) - 1)
    veh_lat = ride_route_coords[ride_step][0]
    veh_lon = ride_route_coords[ride_step][1]
    completed = (ride_step >= len(ride_route_coords) - 1)

    R = 6371
    lat1, lon1 = math.radians(veh_lat), math.radians(veh_lon)
    lat2, lon2 = math.radians(ride_dest_lat), math.radians(ride_dest_lon)
    dlat, dlon = lat2 - lat1, lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
    remaining_km = round(R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)), 2)

    return {
        "vehicleLat": veh_lat, "vehicleLon": veh_lon,
        "distance": remaining_km,
        "eta":   max(1, round(remaining_km * 2)) if not completed else 0,
        "speed": random.randint(28, 48) if not completed else 0,
        "completed": completed
    }


# ----------------------------
# Chat
# ----------------------------
@app.get("/send-message")
def send_message(sender: str, receiver: str, message: str):
    db = SessionLocal()
    try:
        msg = Message(sender=sender, receiver=receiver, message=message)
        db.add(msg)
        db.commit()
        return {"status": "sent"}
    finally:
        db.close()


@app.get("/get-messages")
def get_messages(user: str):
    db = SessionLocal()
    try:
        messages = (
            db.query(Message)
            .filter((Message.sender == user) | (Message.receiver == user))
            .order_by(Message.id)
            .all()
        )
        result = []
        for msg in messages:
            result.append({
                "sender":   msg.sender,
                "receiver": msg.receiver,
                "message":  msg.message,
                "time":     str(msg.created_at)
            })
        return result
    finally:
        db.close()


print("CHAT ENDPOINTS LOADED")

Base.metadata.create_all(bind=engine)
print("Loaded main.py with all endpoints")
