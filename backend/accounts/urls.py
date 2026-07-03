from django.urls import path
from .views import request_email_otp, verify_email_otp, me, register_device, prekey_bundle

urlpatterns = [
    path("request-email-otp/", request_email_otp, name="request-email-otp"),
    path("verify-email-otp/", verify_email_otp, name="verify-email-otp"),
    path("me/", me, name="me"),
    path("devices/register/", register_device, name="device-register"),
    path("devices/prekey-bundle/<uuid:user_id>/", prekey_bundle, name="prekey-bundle"),
]
