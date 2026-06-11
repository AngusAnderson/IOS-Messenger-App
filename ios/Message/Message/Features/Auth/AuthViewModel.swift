import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService()
    private let keychainService = KeychainService()

    init() {
        Task {
            await restoreSession()
        }
    }

    func restoreSession() async {
        guard let token = keychainService.getToken() else { return }

        do {
            let user = try await authService.me(token: token)
            currentUser = user
            isAuthenticated = true
        } catch {
            keychainService.clearToken()
            currentUser = nil
            isAuthenticated = false
        }
    }

    func login() async {
        errorMessage = nil
        isLoading = true

        do {
            let response = try await authService.login(username: username, password: password)
            keychainService.saveToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register() async {
        errorMessage = nil
        isLoading = true

        do {
            let response = try await authService.register(username: username, password: password)
            keychainService.saveToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        keychainService.clearToken()
        username = ""
        password = ""
        currentUser = nil
        isAuthenticated = false
    }
}
