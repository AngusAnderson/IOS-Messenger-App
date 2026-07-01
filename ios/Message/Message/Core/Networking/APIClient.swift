import Foundation

final class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: AppConfig.baseURL)!
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(configuration: configuration)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
    }

    func post<T: Encodable, U: Decodable>(
        path: String,
        body: T,
        token: String? = nil
    ) async throws -> U {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = token, !token.isEmpty {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response)
    }

    func get<U: Decodable>(
        path: String,
        token: String
    ) async throws -> U {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response)
    }

    private func handleResponse<U: Decodable>(data: Data, response: URLResponse) throws -> U {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try decoder.decode(U.self, from: data)
            } catch let error as DecodingError {
                throw APIError.decodingFailed(Self.describeDecodingError(error, data: data))
            } catch {
                throw APIError.decodingFailed("Failed to decode server response.")
            }

        case 401:
            throw APIError.unauthorized

        default:
            throw APIError.serverError(Self.extractErrorMessage(from: data))
        }
    }

    private static func extractErrorMessage(from data: Data) -> String {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let detailResponse = try? decoder.decode(DRFDetailError.self, from: data) {
            return detailResponse.detail
        }

        if let simpleError = try? decoder.decode(SimpleErrorResponse.self, from: data) {
            return simpleError.error
        }

        if let fieldErrors = try? decoder.decode([String: [String]].self, from: data) {
            if let nonFieldErrors = fieldErrors["nonFieldErrors"]?.first {
                return nonFieldErrors
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

    private static func describeDecodingError(_ error: DecodingError, data: Data) -> String {
        let rawBody = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"

        switch error {
        case .typeMismatch(let type, let context):
            return """
            Type mismatch for \(type).
            Path: \(codingPathString(context.codingPath))
            Debug: \(context.debugDescription)
            Response: \(rawBody)
            """

        case .valueNotFound(let type, let context):
            return """
            Missing value for \(type).
            Path: \(codingPathString(context.codingPath))
            Debug: \(context.debugDescription)
            Response: \(rawBody)
            """

        case .keyNotFound(let key, let context):
            return """
            Missing key '\(key.stringValue)'.
            Path: \(codingPathString(context.codingPath))
            Debug: \(context.debugDescription)
            Response: \(rawBody)
            """

        case .dataCorrupted(let context):
            return """
            Corrupted data.
            Path: \(codingPathString(context.codingPath))
            Debug: \(context.debugDescription)
            Response: \(rawBody)
            """

        @unknown default:
            return "Failed to decode server response. Response: \(rawBody)"
        }
    }

    private static func codingPathString(_ codingPath: [CodingKey]) -> String {
        if codingPath.isEmpty { return "<root>" }
        return codingPath.map(\.stringValue).joined(separator: ".")
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case decodingFailed(String)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .decodingFailed(let message):
            return message
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
