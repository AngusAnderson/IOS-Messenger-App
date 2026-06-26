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

    init(from dto: MessageDTO) {
        self.id = dto.id
        self.text = dto.text
        self.isFromCurrentUser = dto.isFromCurrentUser
        self.sentAt = dto.sentAt

        switch dto.deliveryStatus?.lowercased() {
        case "sent":
            self.status = .sent
        case "failed":
            self.status = .failed
        case "sending":
            self.status = .sending
        default:
            self.status = nil
        }
    }
}
