import Foundation

final class APIChatService: ChatServiceProtocol {
    func fetchConversations(token: String) async throws -> [Conversation] {
        let dtos: [ConversationDTO] = try await APIClient.shared.get(
            path: "chat/conversations/",
            token: token
        )

        return dtos.map(Conversation.init(from:))
    }

    func fetchMessages(
        conversationID: UUID,
        token: String,
        currentUserId: Int
    ) async throws -> [Message] {
        let dtos: [MessageDTO] = try await APIClient.shared.get(
            path: "chat/conversations/\(conversationID.uuidString.lowercased())/messages/",
            token: token
        )

        return dtos
            .map { Message(from: $0, currentUserId: currentUserId) }
            .sorted { $0.sentAt < $1.sentAt }
    }

    func sendMessage(
        text: String,
        in conversationID: UUID,
        token: String,
        currentUserId: Int
    ) async throws -> Message {
        let dto: MessageDTO = try await APIClient.shared.post(
            path: "chat/conversations/\(conversationID.uuidString.lowercased())/messages/",
            body: SendMessageBody(text: text),
            token: token
        )

        return Message(from: dto, currentUserId: currentUserId)
    }
}
