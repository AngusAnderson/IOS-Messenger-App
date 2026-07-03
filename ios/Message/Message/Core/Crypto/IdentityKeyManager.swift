import Foundation
import CryptoKit

final class IdentityKeyManager {

    private let keychain: KeychainService
    private let identityKeyAccount = "identity_private_key"

    init(keychain: KeychainService = KeychainService()) {
        self.keychain = keychain
    }

    /// Call once after successful OTP login.
    /// Generates a new keypair only if one does not already exist.
    func bootstrap() throws -> Curve25519.KeyAgreement.PublicKey {
        if let existing = try? loadPrivateKey() {
            return existing.publicKey
        }
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        try savePrivateKey(privateKey)
        return privateKey.publicKey
    }

    func publicKey() throws -> Curve25519.KeyAgreement.PublicKey {
        return try loadPrivateKey().publicKey
    }

    func publicKeyData() throws -> Data {
        return try publicKey().rawRepresentation
    }

    func privateKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        return try loadPrivateKey()
    }

    // MARK: - Private

    private func savePrivateKey(_ key: Curve25519.KeyAgreement.PrivateKey) throws {
        keychain.save(data: key.rawRepresentation, account: identityKeyAccount)
    }

    private func loadPrivateKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        guard let data = keychain.load(account: identityKeyAccount) else {
            throw CryptoError.keyNotFound
        }
        guard let key = try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data) else {
            throw CryptoError.invalidKeyData
        }
        return key
    }
}
