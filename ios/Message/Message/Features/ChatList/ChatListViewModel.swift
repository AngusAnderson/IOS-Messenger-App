import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let chatService: ChatServiceProtocol
    private let authViewModel: AuthViewModel

    init(
        chatService: ChatServiceProtocol,
        authViewModel: AuthViewModel
    ) {
        self.chatService = chatService
        self.authViewModel = authViewModel
    }

    var filteredConversations: [Conversation] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return conversations
        }

        return conversations.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.preview.localizedCaseInsensitiveContains(trimmed) ||
            $0.subtitle.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func loadConversations() async {
        guard let token = authViewModel.token else {
            conversations = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            conversations = try await chatService.fetchConversations(token: token)
        } catch let apiError as APIError {
            handleAPIError(apiError)
        } catch {
            errorMessage = "Couldn't load conversations."
        }

        isLoading = false
    }

    func refreshConversations() async {
        await loadConversations()
    }

    func makeDetailViewModel(for conversation: Conversation) -> ChatDetailViewModel {
        ChatDetailViewModel(
            conversation: conversation,
            chatService: chatService,
            authViewModel: authViewModel
        )
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
