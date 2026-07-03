import Foundation

struct E2EESession: Codable {
    let conversationId: String
    let sharedSecret: Data
    var sendingChainKey: Data
    var receivingChainKey: Data
    var messageIndex: Int
    let aliceEphemeralPublicKey: String
    let oneTimePreKeyId: String?
}
