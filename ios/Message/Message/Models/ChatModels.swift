import Foundation

struct ConversationDTO: Decodable {
    let id: UUID
    let title: String
    let subtitle: String?
    let preview: String?
    let status: String?
    let isGroup: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case preview
        case status
        case isGroup = "is_group"
    }
}

struct MessageDTO: Decodable {
    let id: UUID
    let text: String
    let isFromCurrentUser: Bool
    let sentAt: Date
    let deliveryStatus: String?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case isFromCurrentUser = "is_from_current_user"
        case sentAt = "sent_at"
        case deliveryStatus = "delivery_status"
    }
}

struct SendMessageBody: Encodable {
    let text: String
}
