from django.urls import path
from .views import conversation_list, conversation_messages

urlpatterns = [
    path("conversations/", conversation_list, name="conversation-list"),
    path("conversations/<uuid:conversation_id>/messages/", conversation_messages, name="conversation-messages"),
]
