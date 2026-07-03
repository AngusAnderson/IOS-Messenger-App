import Foundation

actor MockChatStore {
    private var conversations: [Conversation]
    private var messagesByConversationID: [UUID: [Message]]

    init() {
        let conversation1 = Conversation(
            id: UUID(),
            title: "GC Name",
            subtitle: "Tuesday",
            preview: "Lorem Ipsum adlkf alkdjf kl...",
            status: "Pinned",
            isGroup: true
        )

        let conversation2 = Conversation(
            id: UUID(),
            title: "Person Name",
            subtitle: "10-05-26",
            preview: "Lorem Ipsum adlkf alkdjf kl...",
            status: "Read",
            isGroup: false
        )

        self.conversations = [conversation1, conversation2]

        self.messagesByConversationID = [
            conversation1.id: [
                Message(
                    text: "Are we all still good for Tuesday?",
                    isFromCurrentUser: false,
                    sentAt: Date().addingTimeInterval(-3600)
                ),
                Message(
                    text: "Yep, I’m in.",
                    isFromCurrentUser: true,
                    sentAt: Date().addingTimeInterval(-3200)
                ),
                Message(
                    text: "Perfect, see you then.",
                    isFromCurrentUser: false,
                    sentAt: Date().addingTimeInterval(-3000)
                )
            ],
            conversation2.id: [
                Message(
                    text: "Hey, are we still on for later?",
                    isFromCurrentUser: false,
                    sentAt: Date().addingTimeInterval(-2400)
                ),
                Message(
                    text: "Yeah, should be good. Want me to bring anything?",
                    isFromCurrentUser: true,
                    sentAt: Date().addingTimeInterval(-2000)
                ),
                Message(
                    text: "No, all good. Just come through when you're ready.",
                    isFromCurrentUser: false,
                    sentAt: Date().addingTimeInterval(-1600)
                )
            ]
        ]
    }

    func allConversations() -> [Conversation] {
        conversations
    }

    func messages(for conversationID: UUID) -> [Message] {
        messagesByConversationID[conversationID, default: []]
            .sorted { $0.sentAt < $1.sentAt }
    }

    func appendMessage(_ message: Message, to conversationID: UUID) -> Message {
        messagesByConversationID[conversationID, default: []].append(message)

        if let conversationIndex = conversations.firstIndex(where: { $0.id == conversationID }) {
            let existing = conversations[conversationIndex]

            conversations[conversationIndex] = Conversation(
                id: existing.id,
                title: existing.title,
                subtitle: "Today",
                preview: message.text,
                status: "Sent",
                isGroup: existing.isGroup
            )
        }

        conversations.sort { lhs, rhs in
            let lhsLatest = messagesByConversationID[lhs.id]?.last?.sentAt ?? .distantPast
            let rhsLatest = messagesByConversationID[rhs.id]?.last?.sentAt ?? .distantPast
            return lhsLatest > rhsLatest
        }

        return message
    }
}

struct MockChatService: ChatServiceProtocol {
    private let store: MockChatStore

    init(store: MockChatStore = MockChatStore()) {
        self.store = store
    }

    func fetchConversations(token: String) async throws -> [Conversation] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return await store.allConversations()
    }

    func fetchMessages(
        conversationID: UUID,
        token: String,
        currentUserId: String
    ) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return await store.messages(for: conversationID)
    }

    func sendMessage(
        text: String,
        in conversationID: UUID,
        token: String,
        currentUserId: String
    ) async throws -> Message {
        try await Task.sleep(nanoseconds: 300_000_000)

        let message = Message(
            text: text,
            isFromCurrentUser: true,
            sentAt: Date(),
            status: .sent
        )

        return await store.appendMessage(message, to: conversationID)
    }
}
