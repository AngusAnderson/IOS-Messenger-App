import Foundation

protocol ChatServiceProtocol {
    func fetchConversations(token: String) async throws -> [Conversation]

    func fetchMessages(
        conversationID: UUID,
        token: String,
        currentUserId: String
    ) async throws -> [Message]

    func sendMessage(
        text: String,
        in conversationID: UUID,
        token: String,
        currentUserId: String
    ) async throws -> Message
}
