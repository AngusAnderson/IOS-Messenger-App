import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false

    var filteredConversations: [Conversation] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return conversations
        }

        return conversations.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.preview.localizedCaseInsensitiveContains(trimmed) ||
            $0.subtitle.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func loadConversations() async {
        guard conversations.isEmpty else { return }

        isLoading = true

        try? await Task.sleep(nanoseconds: 300_000_000)

        conversations = Conversation.mockData
        isLoading = false
    }

    func messages(for conversation: Conversation) -> [Message] {
        if conversation.isGroup {
            return [
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
            return Message.mockConversation
        }
    }
}
