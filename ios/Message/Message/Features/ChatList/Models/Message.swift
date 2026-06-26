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
    let sentAt: Date
    var status: MessageStatus?
}

extension Message {
    static func mockHistory(referenceDate: Date = Date()) -> [Message] {
        let calendar = Calendar.current

        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: referenceDate) ?? referenceDate
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: referenceDate) ?? referenceDate
        let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate
        let today = referenceDate

        return [
            Message(
                text: "Hey, are you free later this week?",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 17, minute: 10, second: 0, of: threeDaysAgo) ?? referenceDate,
                status: nil
            ),
            Message(
                text: "I think so, what did you have in mind?",
                isFromCurrentUser: true,
                sentAt: calendar.date(bySettingHour: 17, minute: 13, second: 0, of: threeDaysAgo) ?? referenceDate,
                status: .sent
            ),
            Message(
                text: "Wanted to go through the plan before Friday.",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 17, minute: 18, second: 0, of: threeDaysAgo) ?? referenceDate,
                status: nil
            ),
            Message(
                text: "That works for me.",
                isFromCurrentUser: true,
                sentAt: calendar.date(bySettingHour: 17, minute: 20, second: 0, of: threeDaysAgo) ?? referenceDate,
                status: .sent
            ),

            Message(
                text: "Do you want to do afternoon instead?",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 11, minute: 2, second: 0, of: twoDaysAgo) ?? referenceDate,
                status: nil
            ),
            Message(
                text: "Yes, afternoon is easier.",
                isFromCurrentUser: true,
                sentAt: calendar.date(bySettingHour: 11, minute: 5, second: 0, of: twoDaysAgo) ?? referenceDate,
                status: .sent
            ),
            Message(
                text: "Perfect, let’s lock that in.",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 11, minute: 7, second: 0, of: twoDaysAgo) ?? referenceDate,
                status: nil
            ),

            Message(
                text: "Can you send over the updated notes?",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: yesterday) ?? referenceDate,
                status: nil
            ),
            Message(
                text: "Yep, I’ll do that shortly.",
                isFromCurrentUser: true,
                sentAt: calendar.date(bySettingHour: 9, minute: 18, second: 0, of: yesterday) ?? referenceDate,
                status: .sent
            ),
            Message(
                text: "Amazing, thank you.",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 9, minute: 21, second: 0, of: yesterday) ?? referenceDate,
                status: nil
            ),

            Message(
                text: "Are we still on for this afternoon?",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 14, minute: 5, second: 0, of: today) ?? referenceDate,
                status: nil
            ),
            Message(
                text: "Yes, that still works.",
                isFromCurrentUser: true,
                sentAt: calendar.date(bySettingHour: 14, minute: 7, second: 0, of: today) ?? referenceDate,
                status: .sent
            ),
            Message(
                text: "Great, see you then.",
                isFromCurrentUser: false,
                sentAt: calendar.date(bySettingHour: 14, minute: 8, second: 0, of: today) ?? referenceDate,
                status: nil
            )
        ]
        .sorted { $0.sentAt < $1.sentAt }
    }
}
