from rest_framework import serializers
from .models import User


class RequestEmailOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()


class VerifyEmailOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "is_active", "created_at"]
