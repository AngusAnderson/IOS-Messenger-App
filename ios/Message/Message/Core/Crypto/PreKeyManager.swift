import Foundation
import CryptoKit

/// Manages signed prekeys and one-time prekeys.
/// These are the keys the server holds so Alice can initiate
/// a session with Bob even when Bob is offline.
final class PreKeyManager {

    private let keychain: KeychainService
    private let signedPreKeyAccount = "signed_prekey_private"
    private let oneTimePreKeyPrefix = "one_time_prekey_"

    init(keychain: KeychainService = KeychainService()) {
        self.keychain = keychain
    }

    // MARK: - Signed Prekey

    /// Generates a new signed prekey. Returns the public key bytes
    /// ready to be uploaded to the server.
    func generateSignedPreKey() throws -> Data {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        keychain.save(data: privateKey.rawRepresentation, account: signedPreKeyAccount)
        return privateKey.publicKey.rawRepresentation
    }

    func signedPreKeyPrivate() throws -> Curve25519.KeyAgreement.PrivateKey {
        guard let data = keychain.load(account: signedPreKeyAccount) else {
            throw CryptoError.keyNotFound
        }
        guard let key = try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data) else {
            throw CryptoError.invalidKeyData
        }
        return key
    }

    // MARK: - One-Time Prekeys

    /// Generates a batch of one-time prekeys.
    /// Returns an array of (id, publicKeyData) pairs to upload to the server.
    func generateOneTimePreKeys(count: Int = 10) throws -> [(id: String, publicKey: Data)] {
        var result: [(id: String, publicKey: Data)] = []
        for _ in 0..<count {
            let id = UUID().uuidString
            let privateKey = Curve25519.KeyAgreement.PrivateKey()
            keychain.save(
                data: privateKey.rawRepresentation,
                account: oneTimePreKeyPrefix + id
            )
            result.append((id: id, publicKey: privateKey.publicKey.rawRepresentation))
        }
        return result
    }

    func consumeOneTimePreKey(id: String) throws -> Curve25519.KeyAgreement.PrivateKey {
        let account = oneTimePreKeyPrefix + id
        guard let data = keychain.load(account: account) else {
            throw CryptoError.keyNotFound
        }
        guard let key = try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data) else {
            throw CryptoError.invalidKeyData
        }
        // One-time means delete after use
        keychain.delete(account: account)
        return key
    }
}
