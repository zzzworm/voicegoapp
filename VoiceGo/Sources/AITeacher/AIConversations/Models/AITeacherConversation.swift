import Foundation
import GRDB
import SharingGRDB



struct ConversationAnswer: Codable, FetchableRecord, PersistableRecord, Equatable, Identifiable {
    // 数据库主键（如无可自增，或可用UUID）
    var id: Int64? // 可选，数据库自增主键
    let answer: String
    let score: Int
    let revisions: [String] // 假设 revisions 是字符串数组，如有更复杂结构请补充
    let review: String
    let simpleReplay: String
    let formalReplay: String

}
extension ConversationAnswer {
    // MARK: - GRDB Table
    static let databaseTableName = "conversationAnswer"

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case answer
        case score
        case revisions
        case review
        case simpleReplay = "simple_replay"
        case formalReplay = "formal_replay"
    }
}

struct AITeacherConversation : Equatable, Identifiable,TableRecord, Codable  {

    let documentId: String
    let id : Int
    let updatedAt: Date
    let query : String
    var answer : ConversationAnswer
    let message_id: String
    let conversation_id: String
    var ai_teacher: AITeacher? = nil
}

extension AITeacherConversation {
        static var databaseTableName = "aiTeacherHistory"
}