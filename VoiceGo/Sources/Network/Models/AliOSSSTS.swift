import Foundation

public struct AliOSSSTS: Codable, Equatable, Sendable {
    public let accessKeyId: String
    public let accessKeySecret: String
    public let securityToken: String
    public let expiration: String
    public let region: String
    public let bucket: String

    enum CodingKeys: String, CodingKey {
        case accessKeyId = "AccessKeyId"
        case accessKeySecret = "AccessKeySecret"
        case securityToken = "SecurityToken"
        case expiration = "Expiration"
        case region
        case bucket
    }
}
