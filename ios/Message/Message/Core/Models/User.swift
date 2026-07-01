import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let isActive: Bool
    let createdAt: String
}
