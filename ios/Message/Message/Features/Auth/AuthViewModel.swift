import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published var didSendCode: Bool = false

    @Published var token: String?
    @Published var currentUser: User?
    @Published var isRestoringSession: Bool = true

    private let keychain = KeychainService()

    var isAuthenticated: Bool {
        token != nil
    }

    init() {
        Task {
            await restoreSession()
        }
    }

    func restoreSession() async {
        isRestoringSession = true
        errorMessage = nil
        defer { isRestoringSession = false }

        guard let savedToken = keychain.getToken() else {
            token = nil
            currentUser = nil
            return
        }

        do {
            let user = try await AuthService.shared.fetchCurrentUser(token: savedToken)
            token = savedToken
            currentUser = user
        } catch let apiError as APIError {
            switch apiError {
            case .unauthorized:
                clearSession()
            default:
                token = savedToken
                currentUser = nil
                errorMessage = "Couldn't refresh your session right now."
            }
        } catch {
            token = savedToken
            currentUser = nil
            errorMessage = "Couldn't refresh your session right now."
        }
    }

    func requestCode() async {
        errorMessage = nil
        infoMessage = nil

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanedEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let message = try await AuthService.shared.requestEmailOTP(email: cleanedEmail)
            email = cleanedEmail
            infoMessage = message
            didSendCode = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func verifyCode() async {
        errorMessage = nil
        infoMessage = nil

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedEmail.isEmpty else {
            errorMessage = "Missing email address."
            return
        }

        guard cleanedCode.count == 6 else {
            errorMessage = "Enter the 6-digit code."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await AuthService.shared.verifyEmailOTP(email: cleanedEmail, code: cleanedCode)
            token = response.token
            currentUser = response.user
            keychain.saveToken(response.token)
            didSendCode = false
            code = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        clearSession()
    }

    func handleUnauthorized() {
        clearSession()
        errorMessage = "Your session has expired. Please log in again."
    }

    private func clearSession() {
        keychain.clearToken()
        token = nil
        currentUser = nil
        email = ""
        code = ""
        didSendCode = false
        errorMessage = nil
        infoMessage = nil
    }
}
