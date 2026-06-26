import Foundation
import Combine

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var draftMessage = ""
    @Published var isLoading = false
    @Published var isSending = false
    @Published var errorMessage: String?

    let conversation: Conversation

    private let chatService: ChatServiceProtocol
    private let authViewModel: AuthViewModel

    init(
        conversation: Conversation,
        chatService: ChatServiceProtocol,
        authViewModel: AuthViewModel
    ) {
        self.conversation = conversation
        self.chatService = chatService
        self.authViewModel = authViewModel
    }

    var canSendMessage: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var newestMessageID: UUID? {
        messages.last?.id
    }

    func loadMessages() async {
        guard let token = authViewModel.token else {
            messages = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            messages = try await chatService.fetchMessages(
                conversationID: conversation.id,
                token: token
            )
        } catch let apiError as APIError {
            handleAPIError(apiError)
        } catch {
            errorMessage = "Couldn't load messages."
        }

        isLoading = false
    }

    func refreshMessages() async {
        await loadMessages()
    }

    func sendMessage() {
        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }
        guard let token = authViewModel.token else { return }

        let pendingMessage = Message(
            text: trimmed,
            isFromCurrentUser: true,
            sentAt: Date(),
            status: .sending
        )

        messages.append(pendingMessage)
        draftMessage = ""
        isSending = true
        errorMessage = nil

        Task {
            do {
                let sentMessage = try await chatService.sendMessage(
                    text: trimmed,
                    in: conversation.id,
                    token: token
                )

                if let index = messages.firstIndex(where: { $0.id == pendingMessage.id }) {
                    messages[index] = sentMessage
                } else {
                    messages.append(sentMessage)
                    messages.sort { $0.sentAt < $1.sentAt }
                }
            } catch let apiError as APIError {
                handleAPIError(apiError)

                if case .unauthorized = apiError {
                    if let index = messages.firstIndex(where: { $0.id == pendingMessage.id }) {
                        messages.remove(at: index)
                    }
                } else {
                    if let index = messages.firstIndex(where: { $0.id == pendingMessage.id }) {
                        messages[index].status = .failed
                    }
                }
            } catch {
                if let index = messages.firstIndex(where: { $0.id == pendingMessage.id }) {
                    messages[index].status = .failed
                }
                errorMessage = "Couldn't send message."
            }

            isSending = false
        }
    }

    private func handleAPIError(_ error: APIError) {
        switch error {
        case .unauthorized:
            authViewModel.handleUnauthorized()
        default:
            errorMessage = error.localizedDescription
        }
    }
}
