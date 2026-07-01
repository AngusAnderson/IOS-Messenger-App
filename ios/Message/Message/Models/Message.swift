import Foundation

struct Message: Identifiable, Hashable {
    let id: UUID
    let text: String
    let isFromCurrentUser: Bool
    let sentAt: Date
    var status: MessageDeliveryStatus?

    init(
        id: UUID = UUID(),
        text: String,
        isFromCurrentUser: Bool,
        sentAt: Date,
        status: MessageDeliveryStatus? = nil
    ) {
        self.id = id
        self.text = text
        self.isFromCurrentUser = isFromCurrentUser
        self.sentAt = sentAt
        self.status = status
    }

    init(from dto: MessageDTO, currentUserId: Int) {
        self.id = dto.id
        self.text = dto.text
        self.isFromCurrentUser = dto.senderId == String(currentUserId)
        self.sentAt = Self.parseDate(dto.createdAt)
        self.status = nil
    }

    private static func parseDate(_ value: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: value) {
            return date
        }

        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]

        if let date = fallback.date(from: value) {
            return date
        }

        return Date()
    }
}
