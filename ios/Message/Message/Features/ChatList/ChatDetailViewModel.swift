import Foundation
import Combine

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message]
    @Published var draftMessage = ""

    let conversation: Conversation

    init(conversation: Conversation, messages: [Message]? = nil) {
        self.conversation = conversation

        if let messages {
            self.messages = messages
        } else if conversation.isGroup {
            self.messages = [
                Message(
                    text: "Are we all still good for Tuesday?",
                    isFromCurrentUser: false,
                    timestamp: "10:11"
                ),
                Message(
                    text: "Yep, I’m in.",
                    isFromCurrentUser: true,
                    timestamp: "10:13"
                ),
                Message(
                    text: "Perfect, see you then.",
                    isFromCurrentUser: false,
                    timestamp: "10:14"
                )
            ]
        } else {
            self.messages = Message.mockConversation
        }
    }

    var canSendMessage: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func sendMessage() {
        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let newMessage = Message(
            text: trimmed,
            isFromCurrentUser: true,
            timestamp: formatter.string(from: Date())
        )

        messages.append(newMessage)
        draftMessage = ""
    }
}
