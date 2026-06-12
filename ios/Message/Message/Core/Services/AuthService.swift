import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func requestEmailOTP(email: String) async throws -> String {
        let response: APIMessageResponse = try await APIClient.shared.post(
            path: "auth/request-email-otp/",
            body: RequestEmailOTPBody(email: email)
        )
        return response.detail
    }

    func verifyEmailOTP(email: String, code: String) async throws -> AuthResponse {
        return try await APIClient.shared.post(
            path: "auth/verify-email-otp/",
            body: VerifyEmailOTPBody(email: email, code: code)
        )
    }

    func fetchCurrentUser(token: String) async throws -> User {
        return try await APIClient.shared.get(
            path: "auth/me/",
            token: token
        )
    }
}
