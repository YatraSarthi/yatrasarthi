"""
launcher.py  —  single entry point for YatraSarthi.

Replaces the old two-process qmlscene approach with QQmlApplicationEngine
so we can inject a Python BackendBridge object as a QML context property.

The FastAPI server still runs on 127.0.0.1:8000 (started in a background
thread).  The bridge makes synchronous HTTP calls to it and returns JSON
strings back to QML — identical to the contract the QML files already expect.
"""
from PyQt5 import QtWebEngine
QtWebEngine.QtWebEngine.initialize()

import sys
import os
import threading
import uvicorn

# ── 1. Start FastAPI in a background daemon thread ────────────────────────────
def _start_api():
    # Import here so PyQt5 is already imported first (avoids some DLL conflicts)
    from backend.main import app          # your existing FastAPI app object
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="info")

api_thread = threading.Thread(target=_start_api, daemon=True)
api_thread.start()

# ── 2. Build the Qt application and inject the bridge ────────────────────────
from PyQt5.QtGui      import QGuiApplication
from PyQt5.QtQml      import QQmlApplicationEngine
from PyQt5.QtCore     import QObject, pyqtSlot, QUrl

import requests        # pip install requests   (already a FastAPI dependency)
import json

BASE_URL = "http://127.0.0.1:8000"


class BackendBridge(QObject):
    """
    Synchronous HTTP wrapper exposed to QML as the global 'backend' object.
    Every method returns a JSON string so QML can do JSON.parse(backend.xxx()).
    """

    def _post(self, path: str, payload: dict) -> str:
        try:
            r = requests.post(f"{BASE_URL}{path}", json=payload, timeout=10)
            return r.text                   # already JSON from FastAPI
        except Exception as e:
            return json.dumps({"success": False, "message": str(e)})

    def _get(self, path: str, params: dict = None) -> str:
        try:
            r = requests.get(f"{BASE_URL}{path}", params=params, timeout=10)
            return r.text
        except Exception as e:
            return json.dumps({"success": False, "message": str(e)})

    # ── Auth endpoints ────────────────────────────────────────────────────────

    @pyqtSlot(str, str, str, result=str)
    def registerUser(self, name: str, email: str, phone: str) -> str:
        return self._post("/auth/register", {
            "full_name": name,
            "email":     email,
            "phone":     phone,
        })

    @pyqtSlot(str, result=str)
    def sendLoginOTP(self, phone: str) -> str:
        return self._post("/auth/send-login-otp", {"phone": phone})

    @pyqtSlot(str, str, result=str)
    def verifyOTP(self, phone: str, otp: str) -> str:
        return self._post("/auth/verify-otp", {"phone": phone, "otp": otp})

    @pyqtSlot(str, result=str)
    def resendOTP(self, phone: str) -> str:
        return self._post("/auth/resend-otp", {"phone": phone})

    # ── Add more slots here as your app grows ─────────────────────────────────
    # @pyqtSlot(str, str, result=str)
    # def bookRide(self, pickup: str, drop: str) -> str:
    #     return self._post("/rides/book", {"pickup": pickup, "drop": drop})


def main():
    # Give uvicorn a moment to bind before the first QML backend call
    import time
    time.sleep(1)

    qt_app = QGuiApplication(sys.argv)

    engine  = QQmlApplicationEngine()
    bridge  = BackendBridge()

    # 'backend' is now available as a global in every QML file
    engine.rootContext().setContextProperty("backend", bridge)

    root = os.path.dirname(os.path.abspath(__file__))
    engine.load(QUrl.fromLocalFile(os.path.join(root, "app", "AppLoader.qml")))

    if not engine.rootObjects():
        print("ERROR: QML failed to load — check AppLoader.qml for errors.")
        sys.exit(1)

    sys.exit(qt_app.exec_())


if __name__ == "__main__":
    main()


def _start_api():
    print("1. Importing FastAPI...")

    from backend.main import app

    print("2. FastAPI imported")

    print("3. Starting Uvicorn...")

    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000,
        log_level="debug"
    )

    print("4. Uvicorn exited")