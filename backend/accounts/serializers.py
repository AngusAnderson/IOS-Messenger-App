from rest_framework import serializers
from .models import User, Device, OneTimePreKey


class RequestEmailOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()


class VerifyEmailOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "is_active", "created_at"]


class OneTimePreKeySerializer(serializers.Serializer):
    id = serializers.CharField()
    public_key = serializers.CharField()


class DeviceRegistrationSerializer(serializers.Serializer):
    identity_public_key = serializers.CharField()
    signed_prekey = serializers.CharField()
    one_time_prekeys = OneTimePreKeySerializer(many=True)

    def create(self, validated_data):
        user = self.context["request"].user
        prekeys_data = validated_data.pop("one_time_prekeys")

        Device.objects.filter(user=user).delete()

        device = Device.objects.create(
            user=user,
            identity_public_key=validated_data["identity_public_key"],
            signed_prekey=validated_data["signed_prekey"],
        )

        OneTimePreKey.objects.bulk_create([
            OneTimePreKey(
                device=device,
                key_id=pk["id"],
                public_key=pk["public_key"]
            )
            for pk in prekeys_data
        ])

        return device


class PreKeyBundleSerializer(serializers.Serializer):
    """Read-only bundle returned to Alice so she can run X3DH."""
    user_id = serializers.UUIDField(source="user.id")
    identity_public_key = serializers.CharField()
    signed_prekey = serializers.CharField()
    one_time_prekey_id = serializers.SerializerMethodField()
    one_time_prekey = serializers.SerializerMethodField()

    def get_one_time_prekey_id(self, obj):
        prekey = self.context.get("prekey")
        return prekey.key_id if prekey else None

    def get_one_time_prekey(self, obj):
        prekey = self.context.get("prekey")
        return prekey.public_key if prekey else None
