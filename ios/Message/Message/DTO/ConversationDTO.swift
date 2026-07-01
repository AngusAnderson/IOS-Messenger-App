import Foundation

struct ConversationDTO: Codable, Identifiable {
    let id: UUID
    let updatedAt: String
    let lastMessage: MessageDTO?
}

struct MessageDTO: Codable, Identifiable {
    let id: UUID
    let senderId: String
    let text: String
    let createdAt: String
}
