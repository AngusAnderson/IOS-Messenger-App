import Foundation
import CryptoKit

final class DeviceRegistrationService {

    private let identityKeyManager: IdentityKeyManager
    private let preKeyManager: PreKeyManager

    init(
        identityKeyManager: IdentityKeyManager = IdentityKeyManager(),
        preKeyManager: PreKeyManager = PreKeyManager()
    ) {
        self.identityKeyManager = identityKeyManager
        self.preKeyManager = preKeyManager
    }

    func registerDevice() async throws {
        let identityPublicKey = try identityKeyManager.bootstrap()
        let signedPreKeyData = try preKeyManager.generateSignedPreKey()
        let oneTimePreKeys = try preKeyManager.generateOneTimePreKeys(count: 10)

        let payload = DeviceRegistrationPayload(
            identityPublicKey: identityPublicKey.rawRepresentation.base64EncodedString(),
            signedPrekey: signedPreKeyData.base64EncodedString(),
            oneTimePrekeys: oneTimePreKeys.map {
                OneTimePreKeyPayload(id: $0.id, publicKey: $0.publicKey.base64EncodedString())
            }
        )

        let _: APIMessageResponse = try await APIClient.shared.post(
            path: "devices/register/",
            body: payload
        )
    }
}

// MARK: - Payload types

private struct DeviceRegistrationPayload: Encodable {
    let identityPublicKey: String
    let signedPrekey: String
    let oneTimePrekeys: [OneTimePreKeyPayload]
}

private struct OneTimePreKeyPayload: Encodable {
    let id: String
    let publicKey: String
}
