import Foundation
import CryptoKit

final class X3DHService {

    static let shared = X3DHService()

    private let identityKeyManager = IdentityKeyManager()
    private let sessionManager = SessionManager()

    private init() {}

    // MARK: - Fetch bundle + establish session (Alice side)

    func establishSession(
        withUserId userId: String,
        conversationId: String,
        token: String
    ) async throws -> E2EESession {

        // 1. Fetch Bob's prekey bundle from server
        let bundle: PreKeyBundleResponse = try await APIClient.shared.get(
            path: "auth/devices/prekey-bundle/\(userId)/",
            token: token
        )

        // 2. Decode Bob's identity public key
        guard let identityKeyData = Data(base64Encoded: bundle.identityPublicKey) else {
            throw CryptoError.invalidKey
        }
        let bobIdentityKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: identityKeyData)

        // 3. Decode Bob's signed prekey
        guard let signedPreKeyData = Data(base64Encoded: bundle.signedPrekey) else {
            throw CryptoError.invalidKey
        }
        let bobSignedPreKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: signedPreKeyData)

        // 4. Decode Bob's one-time prekey (optional)
        var bobOneTimePreKey: Curve25519.KeyAgreement.PublicKey? = nil
        if let otkBase64 = bundle.oneTimePrekey,
           let otkData = Data(base64Encoded: otkBase64) {
            bobOneTimePreKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: otkData)
        }

        // 5. Get Alice's identity private key
        let aliceIdentityPrivateKey = try identityKeyManager.loadPrivateKey()

        // 6. Generate Alice's ephemeral keypair
        let aliceEphemeralPrivate = Curve25519.KeyAgreement.PrivateKey()
        let aliceEphemeralPublic = aliceEphemeralPrivate.publicKey

        // 7. X3DH: compute the three (or four) DH values
        let dh1 = try aliceIdentityPrivateKey.sharedSecretFromKeyAgreement(with: bobSignedPreKey)
        let dh2 = try aliceEphemeralPrivate.sharedSecretFromKeyAgreement(with: bobIdentityKey)
        let dh3 = try aliceEphemeralPrivate.sharedSecretFromKeyAgreement(with: bobSignedPreKey)

        var sharedSecret: Data
        if let otk = bobOneTimePreKey {
            let dh4 = try aliceEphemeralPrivate.sharedSecretFromKeyAgreement(with: otk)
            sharedSecret = sessionManager.deriveSharedSecret(dh1: dh1, dh2: dh2, dh3: dh3, dh4: dh4)
        } else {
            sharedSecret = sessionManager.deriveSharedSecret(dh1: dh1, dh2: dh2, dh3: dh3, dh4: nil)
        }

        // 8. Build, save and return the session
        let session = E2EESession(
            conversationId: conversationId,
            sharedSecret: sharedSecret,
            sendingChainKey: sharedSecret,
            receivingChainKey: sharedSecret,
            messageIndex: 0,
            aliceEphemeralPublicKey: aliceEphemeralPublic.rawRepresentation.base64EncodedString(),
            oneTimePreKeyId: bundle.oneTimePreKeyId
        )

        try sessionManager.saveSession(session)

        return session
    }
}

// MARK: - Response type

struct PreKeyBundleResponse: Decodable {
    let userId: String
    let identityPublicKey: String
    let signedPrekey: String
    let oneTimePreKeyId: String?
    let oneTimePrekey: String?
}
