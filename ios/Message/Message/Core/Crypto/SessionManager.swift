import Foundation
import CryptoKit

/// Represents an active E2EE session with one other user/device.
/// This is a simplified session that will grow into full Double Ratchet.
struct E2EESession: Codable {
    let conversationId: String
    let sharedSecret: Data      // derived from X3DH, seeds the ratchet
    var sendingChainKey: Data
    var receivingChainKey: Data
    var messageIndex: Int
}

final class SessionManager {
    
    private let keychain: KeychainService
    private let identityKeyManager: IdentityKeyManager
    private let sessionKeyPrefix = "session_"
    
    init(
        keychain: KeychainService = KeychainService(),
        identityKeyManager: IdentityKeyManager = IdentityKeyManager()
    ) {
        self.keychain = keychain
        self.identityKeyManager = identityKeyManager
    }
    
    // MARK: - X3DH Session Initiation (Alice side)
    
    /// Called when Alice wants to message Bob for the first time.
    /// - Parameter bundle: Bob's prekey bundle fetched from the server.
    /// - Returns: The session and the ephemeral public key Alice must send to Bob.
    func initiateSession(
        conversationId: String,
        recipientBundle: PreKeyBundle
    ) throws -> (session: E2EESession, ephemeralPublicKey: Data) {
        
        // Alice's identity key
        let aliceIdentity = try identityKeyManager.privateKey()
        
        // Bob's public keys from the bundle
        guard
            let bobIdentityKey = try? Curve25519.KeyAgreement.PublicKey(
                rawRepresentation: recipientBundle.identityPublicKey
            ),
            let bobSignedPreKey = try? Curve25519.KeyAgreement.PublicKey(
                rawRepresentation: recipientBundle.signedPreKey
            )
        else {
            throw CryptoError.invalidKeyData
        }
        
        // Alice generates an ephemeral keypair for this session only
        let ephemeralKey = Curve25519.KeyAgreement.PrivateKey()
        
        // X3DH: perform DH exchanges and combine into a shared secret
        let dh1 = try aliceIdentity.sharedSecretFromKeyAgreement(with: bobSignedPreKey)
        let dh2 = try ephemeralKey.sharedSecretFromKeyAgreement(with: bobIdentityKey)
        let dh3 = try ephemeralKey.sharedSecretFromKeyAgreement(with: bobSignedPreKey)
        
        // Combine using HKDF
        let combinedSecret = deriveSharedSecret(dh1: dh1, dh2: dh2, dh3: dh3)
        
        let session = E2EESession(
            conversationId: conversationId,
            sharedSecret: combinedSecret,
            sendingChainKey: combinedSecret,
            receivingChainKey: combinedSecret,
            messageIndex: 0
        )
        
        try saveSession(session)
        
        return (session: session, ephemeralPublicKey: ephemeralKey.publicKey.rawRepresentation)
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
    
    private func deriveSharedSecret(
        dh1: SharedSecret,
        dh2: SharedSecret,
        dh3: SharedSecret
    ) -> Data {
        var ikm = Data()
        dh1.withUnsafeBytes { ikm.append(contentsOf: Array($0)) }
        dh2.withUnsafeBytes { ikm.append(contentsOf: Array($0)) }
        dh3.withUnsafeBytes { ikm.append(contentsOf: Array($0)) }
        
        let info = Data("SecureChatX3DH".utf8)
        let salt = Data(repeating: 0, count: 32)
        
        let derived = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: ikm),
            salt: salt,
            info: info,
            outputByteCount: 32
        )
        
        return derived.withUnsafeBytes { Data(Array($0)) }
    }
    
    // MARK: - Supporting types
    
    struct PreKeyBundle {
        let userId: String
        let deviceId: String
        let identityPublicKey: Data
        let signedPreKey: Data
        let signedPreKeySignature: Data
        let oneTimePreKey: Data?
        let oneTimePreKeyId: String?
    }
}
