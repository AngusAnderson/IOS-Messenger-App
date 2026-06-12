import Foundation

struct RequestEmailOTPBody: Codable {
    let email: String
}

struct VerifyEmailOTPBody: Codable {
    let email: String
    let code: String
}

struct APIMessageResponse: Codable {
    let detail: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}
