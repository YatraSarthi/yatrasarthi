from fastapi import FastAPI
from backend.gps import get_location

app = FastAPI()

@app.get("/")
def health():
    return {"status": "working"}

@app.get("/rides")
def rides():
    return [
        {"vehicle": "Auto", "fare": 120, "eta": 4},
        {"vehicle": "Cab", "fare": 180, "eta": 7}
    ]

@app.get("/location")
def location():
    return get_location()