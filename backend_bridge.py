from PySide6.QtCore import QObject, Slot
import json

import api as backend


class BackendBridge(QObject):

    @Slot(str, result=str)
    def sendLoginOTP(self, phone):

        try:

            return json.dumps(
                backend.send_login_otp(phone)
            )

        except Exception as e:

            return json.dumps({
                "success": False,
                "message": str(e)
            })


    @Slot(str, str, str, result=str)
    def registerUser(self, full_name, email, phone):

        try:

            return json.dumps(
                backend.register(
                    full_name,
                    email,
                    phone
                )
            )

        except Exception as e:

            return json.dumps({
                "success": False,
                "message": str(e)
            })


    @Slot(str, str, result=str)
    def verifyOTP(self, phone, otp):

        try:

            return json.dumps(
                backend.verify_otp(
                    phone,
                    otp
                )
            )

        except Exception as e:

            return json.dumps({
                "success": False,
                "message": str(e)
            })


    @Slot(str, result=str)
    def resendOTP(self, phone):

        try:

            return json.dumps(
                backend.resend_otp(phone)
            )

        except Exception as e:

            return json.dumps({
                "success": False,
                "message": str(e)
            })