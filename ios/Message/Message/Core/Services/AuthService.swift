import Foundation

final class AuthService {
    private let api = APIClient.shared

    func login(username: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(username: username, password: password)
        return try await api.post(path: "auth/login/", body: request)
    }

    func register(username: String, password: String) async throws -> AuthResponse {
        let request = RegisterRequest(username: username, password: password)
        return try await api.post(path: "auth/register/", body: request)
    }

    func me(token: String) async throws -> User {
        return try await api.get(path: "auth/me/", token: token)
    }
}
