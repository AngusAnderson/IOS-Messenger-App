from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def conversation_list(request):
    conversations = (
        Conversation.objects
        .filter(participants=request.user)
        .prefetch_related("messages")
        .order_by("-updated_at")
    )
    serializer = ConversationSerializer(conversations, many=True)
    return Response(serializer.data)


@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def conversation_messages(request, conversation_id):
    conversation = get_object_or_404(
        Conversation.objects.prefetch_related("messages"),
        id=conversation_id,
        participants=request.user
    )

    if request.method == "GET":
        messages = conversation.messages.order_by("created_at")
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

    text = request.data.get("text", "").strip()
    if not text:
        return Response(
            {"detail": "Message text is required."},
            status=status.HTTP_400_BAD_REQUEST
        )

    message = Message.objects.create(
        conversation=conversation,
        sender=request.user,
        text=text
    )
    conversation.save(update_fields=["updated_at"])

    serializer = MessageSerializer(message)
    return Response(serializer.data, status=status.HTTP_201_CREATED)
