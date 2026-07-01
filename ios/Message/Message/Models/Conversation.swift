import Foundation

struct Conversation: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let preview: String
    let status: String
    let isGroup: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        preview: String,
        status: String,
        isGroup: Bool
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.preview = preview
        self.status = status
        self.isGroup = isGroup
    }

    init(from dto: ConversationDTO) {
        self.id = dto.id
        self.title = dto.displayName ?? "Conversation"
        self.subtitle = ""
        self.preview = dto.lastMessage?.text ?? "No messages yet"
        self.status = ""
        self.isGroup = false
    }
}
