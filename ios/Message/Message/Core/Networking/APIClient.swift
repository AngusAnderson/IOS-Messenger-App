import Foundation

final class APIClient {
    static let shared = APIClient()

    private init() {}

    let baseURL = URL(string: "http://192.168.7.4:8000/api")!

    func post<T: Encodable, U: Decodable>(
        path: String,
        body: T,
        token: String? = nil
    ) async throws -> U {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.serverError(Self.extractErrorMessage(from: data))
        }

        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw APIError.serverError("Failed to decode server response.")
        }
    }

    func get<U: Decodable>(
        path: String,
        token: String
    ) async throws -> U {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.serverError(Self.extractErrorMessage(from: data))
        }

        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw APIError.serverError("Failed to decode server response.")
        }
    }

    private static func extractErrorMessage(from data: Data) -> String {
        if let detailResponse = try? JSONDecoder().decode(DRFDetailError.self, from: data) {
            return detailResponse.detail
        }

        if let simpleError = try? JSONDecoder().decode(SimpleErrorResponse.self, from: data) {
            return simpleError.error
        }

        if let fieldErrors = try? JSONDecoder().decode([String: [String]].self, from: data) {
            if let nonFieldErrors = fieldErrors["non_field_errors"], let first = nonFieldErrors.first {
                return first
            }

            let messages = fieldErrors.flatMap { key, values in
                values.map {
                    let prettyKey = key
                        .replacingOccurrences(of: "_", with: " ")
                        .capitalized
                    return "\(prettyKey): \($0)"
                }
            }

            if !messages.isEmpty {
                return messages.joined(separator: "\n")
            }
        }

        if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
            return raw
        }

        return "Something went wrong."
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .serverError(let message):
            return message
        }
    }
}

struct DRFDetailError: Decodable {
    let detail: String
}

struct SimpleErrorResponse: Decodable {
    let error: String
}
