import random

from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone

from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .models import User, EmailOTP, Device, OneTimePreKey
from .serializers import (
    RequestEmailOTPSerializer,
    VerifyEmailOTPSerializer,
    UserSerializer,
    DeviceRegistrationSerializer,
    PreKeyBundleSerializer,
)


def generate_otp():
    return f"{random.randint(0, 999999):06d}"


@api_view(["POST"])
@permission_classes([AllowAny])
@authentication_classes([])
def request_email_otp(request):
    serializer = RequestEmailOTPSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    email = serializer.validated_data["email"].lower()
    code = generate_otp()

    EmailOTP.objects.filter(email=email, is_used=False).update(is_used=True)

    otp = EmailOTP.objects.create(
        email=email,
        code=code,
        expires_at=EmailOTP.expiry_time(minutes=10),
    )

    send_mail(
        "Your login code",
        f"Your verification code is {otp.code}. It expires in 10 minutes.",
        settings.DEFAULT_FROM_EMAIL,
        [email],
        fail_silently=False,
    )

    return Response(
        {"detail": "Verification code sent to email."},
        status=status.HTTP_200_OK,
    )


@api_view(["POST"])
@permission_classes([AllowAny])
@authentication_classes([])
def verify_email_otp(request):
    serializer = VerifyEmailOTPSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    email = serializer.validated_data["email"].lower()
    code = serializer.validated_data["code"]

    otp = (
        EmailOTP.objects
        .filter(email=email, code=code, is_used=False)
        .order_by("-created_at")
        .first()
    )

    if not otp:
        return Response(
            {"detail": "Invalid verification code."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if otp.is_expired():
        return Response(
            {"detail": "Verification code has expired."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    otp.is_used = True
    otp.save(update_fields=["is_used"])

    user, _ = User.objects.get_or_create(email=email)
    token, _ = Token.objects.get_or_create(user=user)

    return Response(
        {
            "token": token.key,
            "user": UserSerializer(user).data,
        },
        status=status.HTTP_200_OK,
    )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def me(request):
    return Response(UserSerializer(request.user).data, status=status.HTTP_200_OK)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def register_device(request):
    serializer = DeviceRegistrationSerializer(
        data=request.data,
        context={"request": request}
    )
    if serializer.is_valid():
        serializer.save()
        return Response({"detail": "Device registered."}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def prekey_bundle(request, user_id):
    # Can't fetch your own bundle
    if str(request.user.id) == str(user_id):
        return Response(
            {"detail": "Cannot fetch your own prekey bundle."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    # Get the target user's device
    device = Device.objects.filter(user__id=user_id).first()
    if not device:
        return Response(
            {"detail": "No device registered for this user."},
            status=status.HTTP_404_NOT_FOUND,
        )

    # Consume one unused one-time prekey atomically
    prekey = (
        OneTimePreKey.objects
        .select_for_update()
        .filter(device=device, used=False)
        .first()
    )

    if prekey:
        prekey.used = True
        prekey.save(update_fields=["used"])

    serializer = PreKeyBundleSerializer(
        device,
        context={"prekey": prekey}
    )
    return Response(serializer.data, status=status.HTTP_200_OK)
