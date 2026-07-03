import Foundation

enum CryptoError: Error, LocalizedError {
    case keyGenerationFailed
    case keyNotFound
    case keystoreFailure(OSStatus)
    case invalidKeyData
    case invalidKey
    case sessionNotFound
    case encryptionFailed
    case decryptionFailed
    case invalidMessage
    case keyAgreementFailed

    var errorDescription: String? {
        switch self {
        case .keyGenerationFailed:    return "Failed to generate cryptographic key"
        case .keyNotFound:            return "Required key not found in keychain"
        case .keystoreFailure(let s): return "Keychain error: \(s)"
        case .invalidKeyData:         return "Key data is invalid or corrupted"
        case .invalidKey:             return "Key is invalid or could not be decoded"
        case .sessionNotFound:        return "No active session found for this conversation"
        case .encryptionFailed:       return "Message encryption failed"
        case .decryptionFailed:       return "Message decryption failed"
        case .invalidMessage:         return "Message format is invalid"
        case .keyAgreementFailed:     return "Key agreement (X3DH) failed"
        }
    }
}
