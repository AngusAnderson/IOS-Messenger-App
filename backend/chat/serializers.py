from rest_framework import serializers
from .models import Conversation, Message


class MessageSerializer(serializers.ModelSerializer):
    sender_id = serializers.UUIDField(source="sender.id", read_only=True)

    class Meta:
        model = Message
        fields = ["id", "sender_id", "text", "created_at"]


class ConversationSerializer(serializers.ModelSerializer):
    last_message = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ["id", "updated_at", "last_message"]

    def get_last_message(self, obj):
        message = obj.messages.order_by("-created_at").first()
        if not message:
            return None
        return MessageSerializer(message).data
