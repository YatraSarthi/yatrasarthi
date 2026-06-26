import sys

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from backend_bridge import BackendBridge


app = QApplication(sys.argv)

engine = QQmlApplicationEngine()

bridge = BackendBridge()

engine.rootContext().setContextProperty("backend", bridge)

engine.load("app/AppLoader.qml")

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())