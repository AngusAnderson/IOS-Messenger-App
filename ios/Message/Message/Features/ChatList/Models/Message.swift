import Foundation

enum MessageStatus: String, Hashable {
    case sending
    case sent
    case failed
}

struct Message: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: String
    var status: MessageStatus?
}

extension Message {
    static let mockConversation: [Message] = [
        Message(
            text: "Hey, are you free later today?",
            isFromCurrentUser: false,
            timestamp: "18:42",
            status: nil
        ),
        Message(
            text: "Yeah, I should be.",
            isFromCurrentUser: true,
            timestamp: "18:44",
            status: .sent
        ),
        Message(
            text: "Perfect, I wanted to talk through everything properly.",
            isFromCurrentUser: false,
            timestamp: "18:45",
            status: nil
        ),
        Message(
            text: "Sounds good to me.",
            isFromCurrentUser: true,
            timestamp: "18:46",
            status: .sent
        )
    ]
}
