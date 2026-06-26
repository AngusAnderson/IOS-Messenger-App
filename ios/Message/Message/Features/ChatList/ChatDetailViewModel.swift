import Foundation
import Combine

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var draftMessage = ""
    @Published var isLoadingOlderMessages = false
    @Published var hasMoreOlderMessages = true

    let conversation: Conversation

    private let nowProvider: () -> Date
    private let pageSize = 20
    private let allMessagesAscending: [Message]

    init(
        conversation: Conversation,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.conversation = conversation
        self.nowProvider = nowProvider

        if conversation.isGroup {
            let now = nowProvider()
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now

            self.allMessagesAscending = [
                Message(
                    text: "Are we all still good for Tuesday?",
                    isFromCurrentUser: false,
                    sentAt: calendar.date(bySettingHour: 20, minute: 11, second: 0, of: yesterday) ?? now,
                    status: nil
                ),
                Message(
                    text: "Yep, I’m in.",
                    isFromCurrentUser: true,
                    sentAt: calendar.date(bySettingHour: 20, minute: 13, second: 0, of: yesterday) ?? now,
                    status: .sent
                ),
                Message(
                    text: "Perfect, see you then.",
                    isFromCurrentUser: false,
                    sentAt: calendar.date(bySettingHour: 10, minute: 14, second: 0, of: now) ?? now,
                    status: nil
                ),
                Message(
                    text: "I’ll bring the docs.",
                    isFromCurrentUser: true,
                    sentAt: calendar.date(bySettingHour: 10, minute: 16, second: 0, of: now) ?? now,
                    status: .sent
                ),
                Message(
                    text: "Nice one.",
                    isFromCurrentUser: false,
                    sentAt: calendar.date(bySettingHour: 10, minute: 17, second: 0, of: now) ?? now,
                    status: nil
                ),
                Message(
                    text: "Can you send over the updated notes?",
                    isFromCurrentUser: false,
                    sentAt: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now) ?? now,
                    status: nil
                ),
                Message(
                    text: "Yep, I’ll do that shortly.",
                    isFromCurrentUser: true,
                    sentAt: calendar.date(bySettingHour: 9, minute: 18, second: 0, of: now) ?? now,
                    status: .sent
                ),
                Message(
                    text: "Amazing, thank you.",
                    isFromCurrentUser: false,
                    sentAt: calendar.date(bySettingHour: 9, minute: 19, second: 0, of: now) ?? now,
                    status: nil
                )
            ]
            .sorted { $0.sentAt < $1.sentAt }
        } else {
            self.allMessagesAscending = Message.mockHistory(referenceDate: nowProvider())
                .sorted { $0.sentAt < $1.sentAt }
        }

        loadInitialMessages()
    }

    var canSendMessage: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var newestMessageID: UUID? {
        messages.last?.id
    }

    func loadInitialMessages() {
        let initialCount = min(pageSize, allMessagesAscending.count)
        messages = Array(allMessagesAscending.suffix(initialCount))
        hasMoreOlderMessages = messages.count < allMessagesAscending.count
    }

    func loadOlderMessages() async {
        guard !isLoadingOlderMessages, hasMoreOlderMessages else { return }

        isLoadingOlderMessages = true
        defer { isLoadingOlderMessages = false }

        try? await Task.sleep(nanoseconds: 300_000_000)

        guard let oldestCurrentlyLoaded = messages.first,
              let oldestIndex = allMessagesAscending.firstIndex(where: { $0.id == oldestCurrentlyLoaded.id }) else {
            hasMoreOlderMessages = false
            return
        }

        guard oldestIndex > 0 else {
            hasMoreOlderMessages = false
            return
        }

        let nextStartIndex = max(0, oldestIndex - pageSize)
        let olderSlice = allMessagesAscending[nextStartIndex..<oldestIndex]

        messages.insert(contentsOf: olderSlice, at: 0)
        hasMoreOlderMessages = nextStartIndex > 0
    }

    func sendMessage() {
        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = Message(
            text: trimmed,
            isFromCurrentUser: true,
            sentAt: nowProvider(),
            status: .sending
        )

        messages.append(newMessage)
        draftMessage = ""

        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)

            if let index = messages.firstIndex(where: { $0.id == newMessage.id }) {
                messages[index].status = .sent
            }
        }
    }
}
