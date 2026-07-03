import Foundation
import CryptoKit

final class SessionManager {

    private let keychain: KeychainService
    private let sessionKeyPrefix = "session_"

    init(keychain: KeychainService = KeychainService()) {
        self.keychain = keychain
    }

    // MARK: - Session Retrieval

    func loadSession(conversationId: String) throws -> E2EESession {
        let account = sessionKeyPrefix + conversationId
        guard let data = keychain.load(account: account) else {
            throw CryptoError.sessionNotFound
        }
        guard let session = try? JSONDecoder().decode(E2EESession.self, from: data) else {
            throw CryptoError.invalidKeyData
        }
        return session
    }

    func saveSession(_ session: E2EESession) throws {
        let account = sessionKeyPrefix + session.conversationId
        guard let data = try? JSONEncoder().encode(session) else {
            throw CryptoError.encryptionFailed
        }
        keychain.save(data: data, account: account)
    }

    // MARK: - HKDF derivation

    func deriveSharedSecret(
        dh1: SharedSecret,
        dh2: SharedSecret,
        dh3: SharedSecret,
        dh4: SharedSecret?
    ) -> Data {
        var ikm = Data()
        dh1.withUnsafeBytes { ikm.append(contentsOf: $0) }
        dh2.withUnsafeBytes { ikm.append(contentsOf: $0) }
        dh3.withUnsafeBytes { ikm.append(contentsOf: $0) }
        dh4?.withUnsafeBytes { ikm.append(contentsOf: $0) }

        let info = Data("SecureChatX3DH".utf8)

        let derived = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: ikm),
            info: info,
            outputByteCount: 32
        )

        return derived.withUnsafeBytes { Data($0) }
    }
}
