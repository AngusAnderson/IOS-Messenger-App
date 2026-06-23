import Foundation

struct Conversation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let preview: String
    let status: String
    let isGroup: Bool
}

extension Conversation {
    static let mockData: [Conversation] = [
        Conversation(
            title: "GC Name",
            subtitle: "Tuesday",
            preview: "Lorem Ipsum adlkf alkdjf kl...",
            status: "Pinned",
            isGroup: true
        ),
        Conversation(
            title: "Person Name",
            subtitle: "10-05-26",
            preview: "Lorem Ipsum adlkf alkdjf kl...",
            status: "Read",
            isGroup: false
        )
    ]
}
