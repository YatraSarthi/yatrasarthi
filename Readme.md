**🚖 YatraSarthi**



**🚖 About YatraSarthi**

YatraSarthi is an open-source ride-hailing platform inspired by modern transportation services such as Uber and Ola. The project demonstrates how a complete transportation ecosystem can be developed entirely using Free and Open Source Software (FOSS).

The application provides OTP-based authentication, interactive map-based ride booking, live ride tracking, route visualization, ride history, favourites, SOS services, rider-driver messaging, and secure backend communication.

Unlike many proprietary ride-booking solutions, YatraSarthi has been designed as a modular educational platform that allows developers and students to understand how modern ride-hailing systems work while leveraging open technologies.

**🎯 Why We Built YatraSarthi**

The motivation behind YatraSarthi was to demonstrate that a feature-rich ride-booking application can be developed using open-source technologies without relying on proprietary ecosystems.

Our goals were to:

- Build a complete ride-booking workflow from scratch.
- Learn modern backend development using FastAPI.
- Explore native application development with Qt/QML.
- Integrate interactive maps using OpenStreetMap.
- Implement secure OTP-based authentication.
- Learn PostgreSQL database design.
- Promote Free and Open Source Software (FOSS).
- Explore Ubuntu Touch application development.

The project serves as both a practical learning experience and a foundation for future research and development in open mobility solutions.

**🌍 Ubuntu Touch & FOSS**

YatraSarthi was developed with Ubuntu Touch compatibility in mind. By building the frontend using Qt Quick (QML), the application follows technologies that are native to Ubuntu Touch, making future deployment to Ubuntu Touch devices significantly easier.

This project embraces the philosophy of Free and Open Source Software (FOSS). Almost every major component used in YatraSarthi is open source, allowing developers to inspect, modify, extend, and contribute to the codebase.

**Open Source Technologies Used**

- Ubuntu Linux
- Ubuntu Touch
- Python
- FastAPI
- PostgreSQL
- SQLAlchemy
- Qt
- Qt Quick (QML)
- Leaflet.js
- OpenStreetMap
- OSRM (Open Source Routing Machine)
- Android SMS Gateway
- Git
- GitHub

By choosing open-source technologies, YatraSarthi demonstrates how powerful software ecosystems can be built without vendor lock-in.

**✨ Key Features**

- 📱 OTP-based Login & Registration
- 🔐 JWT Authentication
- 🗺️ Interactive Leaflet Maps
- 📍 OpenStreetMap Integration
- 🚖 Ride Booking
- 🚘 Live Ride Tracking
- 🛣️ Route Visualization using OSRM
- ❤️ Favourite Locations
- 🕒 Ride History
- 💬 Rider-Driver Chat
- 🚨 SOS Module
- 🔎 Address Search
- 📌 Reverse Geocoding
- 👤 Account Management

**🏗️ System Architecture**

┌─────────────────────┐

│ Qt/QML Frontend │

└──────────┬──────────┘

│

Backend Bridge

│

┌──────────▼──────────┐

│ FastAPI API │

└──────────┬──────────┘

│

┌──────────────┬──────────────┬───────────────┐

│ │ │ │

PostgreSQL SMS Gateway Leaflet.js OSRM Routing

│

OpenStreetMap

**🚀 Project Status**

**✅ Completed**

- OTP Authentication
- JWT Authentication
- User Registration
- User Login
- Interactive Maps
- Ride Booking
- Ride Tracking
- Route Generation
- Favourite Locations
- Ride History
- SOS
- Chat
- Reverse Geocoding

**🚧 Planned**

- Driver Mobile Application
- Payment Gateway
- Push Notifications
- Ride Scheduling
- Ratings & Reviews
- AI-based ETA Prediction
- Admin Dashboard
- Ride Analytics

**⚙️ Technology Stack**

| **Category**         | **Technologies**                    |
| -------------------- | ----------------------------------- |
| Frontend             | Qt Quick (QML), Qt Quick Controls 2 |
| Backend              | FastAPI                             |
| Database             | PostgreSQL                          |
| ORM                  | SQLAlchemy                          |
| Authentication       | JWT                                 |
| Maps                 | Leaflet.js                          |
| Map Provider         | OpenStreetMap                       |
| Routing              | OSRM                                |
| OTP                  | Android SMS Gateway                 |
| Programming Language | Python 3.11                         |
| Version Control      | Git & GitHub                        |

**📋 Prerequisites**

Before running YatraSarthi, ensure the following software is installed:

- Python **3.11**
- PostgreSQL **15** or later
- Qt **5.15**
- PyQt5
- PyQtWebEngine
- Git
- Ubuntu 22.04 LTS (Recommended)
- Ubuntu Touch SDK (Optional for deployment)
- Internet connection (required for maps and routing)

**📦 Python Dependencies**

Install all required Python packages using:

pip install -r requirements.txt

The complete list of dependencies is provided in the requirements.txt file included with this project.

**📂 Project Structure**

YatraSarthi/

│

├── app/ # Qt/QML Frontend

│ ├── assets/

│ │ ├── icons/

│ │ ├── images/

│ │ └── animations/

│ │

│ ├── auth/

│ │ ├── Login.qml

│ │ ├── Register.qml

│ │ └── OTP.qml

│ │

│ ├── components/

│ │

│ ├── pages/

│ │ ├── Home.qml

│ │ ├── Booking.qml

│ │ ├── RideTracking.qml

│ │ ├── Chat.qml

│ │ ├── SOS.qml

│ │ ├── History.qml

│ │ └── Account.qml

│ │

│ ├── web/

│ │ ├── map.html

│ │ └── js/

│ │

│ ├── AppLoader.qml

│ ├── RideApp.qml

│ └── AppState.qml

│

├── backend/

│ ├── auth.py

│ ├── config.py

│ ├── database.py

│ ├── gps.py

│ ├── main.py

│ ├── models.py

│ ├── otp.py

│ ├── routes.py

│ ├── schemas.py

│ ├── sms.py

│ └── .env

│

├── requirements.txt

├── launcher.py

├── README.md

└── LICENSE

**⚙️ Installation**

**1\. Clone the Repository**

git clone <https://github.com/<username>/YatraSarthi.git>

cd YatraSarthi

**2\. Create a Virtual Environment**

**Linux / Ubuntu**

python3 -m venv venv

source venv/bin/activate

**Windows**

python -m venv venv

venv\\Scripts\\activate

**3\. Install Dependencies**

pip install -r requirements.txt

**🗄️ PostgreSQL Setup**

Create a PostgreSQL database.

CREATE DATABASE &lt;database_name&gt;;

Create a PostgreSQL user.

CREATE USER &lt;database_user&gt;

WITH PASSWORD '&lt;your_password&gt;';

Grant privileges.

GRANT ALL PRIVILEGES

ON DATABASE &lt;database_name&gt;

TO &lt;database_user&gt;;

Verify the connection.

psql -U &lt;database_user&gt; -d &lt;database_name&gt;

**🔑 Environment Variables**

Create the following file.

backend/.env

Example configuration:

DATABASE_URL=postgresql://&lt;db_user&gt;:&lt;db_password&gt;@localhost:5432/&lt;database_name&gt;

JWT_SECRET=&lt;your_jwt_secret&gt;

SMSGATE_USERNAME=&lt;your_sms_gateway_username&gt;

SMSGATE_PASSWORD=&lt;your_sms_gateway_password&gt;

SMSGATE_DEVICE_ID=&lt;your_device_id&gt;

**Security Note**

Never commit your actual database credentials, JWT secret, or SMS Gateway credentials to a public repository.  
Use placeholder values in documentation and keep your local .env file excluded via .gitignore.

**📱 SMS Gateway Setup**

YatraSarthi uses the **Android SMS Gateway** project for OTP delivery.

Repository:

<https://github.com/capcom6/android-sms-gateway>

We sincerely thank **Capcom6** and all contributors for making this excellent open-source project available.

**Configuration Steps**

**Step 1**

Install **Android SMS Gateway** on your Android device.

**Step 2**

Open the application.

Enable

Cloud Server

The status should become

ONLINE

**Step 3**

Open

Settings

Copy the following values.

- Username
- Password
- Device ID

**Step 4**

Update your

backend/.env

file.

SMSGATE_USERNAME=&lt;your_username&gt;

SMSGATE_PASSWORD=&lt;your_password&gt;

SMSGATE_DEVICE_ID=&lt;your_device_id&gt;

**Step 5**

Restart the backend.

python launcher.py

**Step 6**

Register or Login using your mobile number.

If configured correctly, the OTP will be delivered to your Android device through the SMS Gateway.

**▶️ Running the Project**

Start the complete application.

python launcher.py

The launcher automatically

- Starts the FastAPI backend
- Creates the Backend Bridge
- Launches the Qt/QML application
- Connects the frontend with the backend

**Backend Only**

uvicorn backend.main:app --reload

**API Documentation**

Once the backend is running, open

<http://127.0.0.1:8000/docs>

to access the automatically generated Swagger UI.

**🌐 REST API**

| **Endpoint**         | **Method** | **Description**        |
| -------------------- | ---------- | ---------------------- |
| /auth/register       | POST       | Register a new user    |
| /auth/send-login-otp | POST       | Send login OTP         |
| /auth/verify-otp     | POST       | Verify OTP             |
| /auth/resend-otp     | POST       | Resend OTP             |
| /route               | GET        | Generate route         |
| /estimate            | GET        | Fare estimation        |
| /search-location     | GET        | Search locations       |
| /reverse-geocode     | GET        | Reverse geocoding      |
| /ride-history        | GET        | Retrieve ride history  |
| /recent-places       | GET/POST   | Manage recent places   |
| /favourites          | GET        | Favourite locations    |
| /sos                 | GET        | SOS service            |
| /send-message        | GET        | Send chat message      |
| /get-messages        | GET        | Retrieve chat messages |

**🔒 Security**

YatraSarthi follows basic security practices to protect user data and application integrity.

Implemented security features include:

- OTP-based user verification
- JWT authentication
- Secure environment variable configuration
- PostgreSQL backend storage
- Separation of frontend and backend logic
- SMS Gateway authentication

Future enhancements include:

- Password-based authentication
- Refresh tokens
- HTTPS deployment
- Role-based access control
- API rate limiting
- End-to-end encrypted messaging

**🔧 Troubleshooting**

This section covers the most common issues encountered during development and deployment of YatraSarthi.

**PostgreSQL Authentication Failed**

**Error**

FATAL: password authentication failed for user

**Solution**

- Verify your PostgreSQL username and password.
- Ensure DATABASE_URL inside backend/.env is correct.
- Test the connection manually.

psql -U &lt;database_user&gt; -d &lt;database_name&gt;

**Database Connection Failed**

**Error**

could not connect to server

**Solution**

- Ensure PostgreSQL service is running.

Ubuntu

sudo systemctl status postgresql

Start if necessary.

sudo systemctl start postgresql

**Port 8000 Already in Use**

**Error**

Address already in use

Find the running process.

lsof -i :8000

Terminate it.

kill -9 &lt;PID&gt;

Restart the backend.

**Backend Timeout**

**Error**

HTTPConnectionPool

Read timed out

This usually indicates that the backend is not responding.

Verify the backend is running.

python launcher.py

or

uvicorn backend.main:app --reload

**OTP Not Received**

Verify that

- SMS Gateway Cloud Server is ONLINE.
- Username is correct.
- Password is correct.
- Device ID matches the Android device.
- Mobile network is available.
- SMS permissions are granted.

**SMS Gateway Authentication Failed**

**Error**

401 Unauthorized

Solution

Open the Android SMS Gateway application.

Navigate to

Settings → Credentials

Copy

- Username
- Password
- Device ID

Update your .env file and restart the backend.

**QtWebEngine Module Missing**

**Error**

module "QtWebEngine" is not installed

Install

pip install PyQtWebEngine

**Blank Map**

Possible causes

- Internet connection unavailable
- OpenStreetMap unreachable
- Backend not running
- QtWebEngine missing

**Logo Not Displayed**

Verify the logo exists.

app/assets/icons/logo.jpeg

Check the filename and extension.

**Phone Already Registered**

Delete the test user.

DELETE FROM users

WHERE phone='&lt;phone_number&gt;';

DELETE FROM otp_store

WHERE phone='&lt;phone_number&gt;';

**FastAPI Documentation Not Opening**

Verify the backend is running.

Open

<http://127.0.0.1:8000/docs>

If unavailable, ensure port **8000** is free.

**❓ Frequently Asked Questions**

**Which operating systems are supported?**

The project is primarily developed and tested on Ubuntu Linux.

It also runs on:

- Windows
- Windows WSL2
- Ubuntu Touch (frontend deployment)

**Which database does YatraSarthi use?**

PostgreSQL.

**Which Python version is recommended?**

Python **3.11**.

**Why was FastAPI chosen?**

FastAPI provides:

- High performance
- Automatic API documentation
- Type safety
- Easy integration with Python applications

**Why Qt/QML?**

Qt Quick (QML) enables the creation of responsive native interfaces while maintaining compatibility with Ubuntu Touch.

**Why Ubuntu Touch?**

Ubuntu Touch is an open-source mobile operating system based on Linux.

Since Ubuntu Touch applications are developed using Qt/QML, YatraSarthi can be adapted for Ubuntu Touch deployment with minimal changes.

**Why OpenStreetMap?**

OpenStreetMap is a community-driven mapping platform.

Benefits include:

- Free
- Open
- No licensing costs
- Highly customizable
- Strong community support

**Why Leaflet?**

Leaflet provides lightweight and highly customizable interactive maps that integrate seamlessly with OpenStreetMap.

**Why OSRM?**

OSRM (Open Source Routing Machine) provides efficient route generation using OpenStreetMap data.

**Why Android SMS Gateway?**

Instead of relying on paid SMS providers, YatraSarthi uses the open-source Android SMS Gateway project, allowing OTPs to be delivered through an Android device.

**Can another SMS provider be used?**

Yes.

Simply replace the implementation in

backend/sms.py

with any SMS provider exposing a REST API.

**Is this production ready?**

Current Version

Educational / Prototype

The application demonstrates a complete ride-hailing workflow but would require additional work before commercial deployment.

**🚀 Future Enhancements**

The following features are planned for future releases.

**Driver Module**

- Driver Login
- Driver Dashboard
- Driver Availability

**Payment Integration**

- UPI
- Razorpay
- Stripe

**Ride Scheduling**

Allow users to pre-book rides.

**Push Notifications**

Real-time notifications for

- Ride Accepted
- Driver Arrived
- Ride Completed

**AI Features**

- ETA Prediction
- Demand Forecasting
- Fare Prediction
- Smart Route Optimization

**Admin Dashboard**

- User Management
- Driver Management
- Ride Analytics
- Revenue Dashboard

**Cloud Deployment**

Deploy backend using

- Docker
- Nginx
- Gunicorn
- Cloud VPS

**Ubuntu Touch Release**

A native Ubuntu Touch application package is planned for future versions.

This will allow YatraSarthi to run as a complete ride-booking application on Ubuntu Touch devices.

**📈 Project Roadmap**

| **Version** | **Planned Features**               |
| ----------- | ---------------------------------- |
| v1.0        | Authentication, Maps, Ride Booking |
| v1.1        | Chat, Ride History, SOS            |
| v1.2        | Payment Gateway                    |
| v2.0        | Driver Application                 |
| v2.5        | Push Notifications                 |
| v3.0        | AI-assisted Ride Management        |

**🤝 Contributing**

Contributions are always welcome.

Whether you would like to fix a bug, improve documentation, optimize performance, or introduce new features, your contributions help improve YatraSarthi.

**How to Contribute**

**1\. Fork the Repository**

Click the **Fork** button on GitHub.

**2\. Clone Your Fork**

git clone <https://github.com/<your-username>/YatraSarthi.git>

cd YatraSarthi

**3\. Create a New Branch**

git checkout -b feature/your-feature-name

**4\. Make Your Changes**

Follow the existing project structure and coding style.

**5\. Commit Changes**

git add .

git commit -m "Add your feature description"

**6\. Push**

git push origin feature/your-feature-name

**7\. Create a Pull Request**

Submit a Pull Request describing:

- What was changed
- Why it was changed
- Screenshots (if UI related)

**📜 Coding Guidelines**

Please follow these guidelines while contributing.

**Python**

- Follow **PEP 8**
- Use meaningful variable names.
- Write reusable functions.
- Keep business logic separate from UI.

**Qt / QML**

- Use reusable components whenever possible.
- Maintain consistent indentation.
- Keep UI logic independent from backend logic.

**Git**

Write meaningful commit messages.

Good examples

Add ride tracking animation

Fix OTP timeout

Improve map performance

Add SOS module

Avoid

Update

Fix

Changes

Final

**🌱 Why Open Source?**

YatraSarthi was created not only as a ride-hailing application but also as a learning platform for students and developers interested in modern application development.

By making the project open source, we hope to encourage learning, collaboration, and innovation.

We strongly believe that knowledge grows when it is shared.

**❤️ Acknowledgements**

YatraSarthi would not have been possible without the amazing Free and Open Source Software community.

We sincerely thank all the maintainers, contributors, and organizations behind the technologies that power this project.

**Ubuntu**

Ubuntu provides the Linux ecosystem used throughout the development of YatraSarthi.

<https://ubuntu.com/>

**Ubuntu Touch**

Ubuntu Touch inspired the choice of Qt/QML as the primary frontend technology and serves as one of the target platforms for future deployment.

<https://ubuntu-touch.io/>

**Qt & Qt Quick (QML)**

Qt provides the native application framework used for building the frontend interface.

<https://www.qt.io/>

**FastAPI**

FastAPI powers the REST backend and API layer.

<https://fastapi.tiangolo.com/>

**PostgreSQL**

PostgreSQL serves as the primary relational database management system.

<https://www.postgresql.org/>

**SQLAlchemy**

SQLAlchemy provides the ORM used for communicating with PostgreSQL.

<https://www.sqlalchemy.org/>

**Leaflet.js**

Leaflet is used to render interactive maps within the application.

<https://leafletjs.com/>

**OpenStreetMap**

OpenStreetMap provides the open geographic data used for mapping and geocoding.

<https://www.openstreetmap.org/>

**OSRM**

Open Source Routing Machine is used for route generation and navigation.

<https://project-osrm.org/>

**Android SMS Gateway**

YatraSarthi uses the **Android SMS Gateway** project developed by **Capcom6** for OTP delivery.

Repository:

<https://github.com/capcom6/android-sms-gateway>

Special thanks to the maintainers and contributors of this project for providing a reliable and open-source SMS gateway solution.

**👥 Project Team**

YatraSarthi was developed as a collaborative academic project.

**Team Members**

- **Manaswitha**
- **Johney Reji Thaliath**
- **Lokesh A**
- **Satyakam Tripathy**

**📄 License**

MIT License

Copyright (c) 2026 YatraSarthi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
- The Software is provided **"AS IS"**, without warranty of any kind, express or implied.
- The authors shall not be liable for any claim, damages, or other liability arising from the use of this Software.

For the complete license text, see the **LICENSE** file included in this repository.

**📚 References**

The following resources were used during the design and development of YatraSarthi.

- FastAPI Documentation - <https://fastapi.tiangolo.com/>
- Qt Documentation - <https://doc.qt.io/>
- Qt for Python (PyQt) Documentation
- PostgreSQL Documentation - <https://www.postgresql.org/docs/>
- SQLAlchemy Documentation - <https://docs.sqlalchemy.org/>
- OpenStreetMap - <https://www.openstreetmap.org/>
- Leaflet Documentation - <https://leafletjs.com/>
- OSRM Documentation - <https://project-osrm.org/>
- Android SMS Gateway (Capcom6) - <https://github.com/capcom6/android-sms-gateway>
- Ubuntu Documentation - <https://ubuntu.com/>
- Ubuntu Touch Documentation - <https://ubuntu-touch.io/>

**⭐ Support the Project**

If you find YatraSarthi useful or interesting:

- ⭐ Star the repository
- 🍴 Fork the project
- 🐛 Report bugs
- 💡 Suggest new features
- 🤝 Contribute through Pull Requests

Your support helps improve the project and encourages continued development.

**🚖 YatraSarthi - Your Journey, Our Priority**

Built with ❤️ using Free and Open Source Software.
