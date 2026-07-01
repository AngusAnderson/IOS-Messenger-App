from rest_framework import serializers
from .models import Conversation, Message

class MessageSerializer(serializers.ModelSerializer):
    sender_id = serializers.CharField(source="sender.id")

    class Meta:
        model = Message
        fields = ["id", "sender_id", "text", "created_at"]


class ConversationSerializer(serializers.ModelSerializer):
    last_message = MessageSerializer(read_only=True)
    display_name = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ["id", "updated_at", "display_name", "last_message"]

    def get_display_name(self, obj):
        request = self.context.get("request")
        user = getattr(request, "user", None)

        participants = obj.participants.all()

        if user and user.is_authenticated:
            other_participant = participants.exclude(pk=user.pk).first()
            if other_participant and other_participant.email:
                return other_participant.email

        first_other = participants.first()
        if first_other and first_other.email:
            return first_other.email

        return "No email"
