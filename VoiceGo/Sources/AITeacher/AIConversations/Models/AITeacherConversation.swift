import Foundation
import GRDB
import SharingGRDB
import ExyteChat

struct ConversationAnswer: Codable, FetchableRecord, PersistableRecord, Equatable, Identifiable {
    // 数据库主键（如无可自增，或可用UUID）
    var id: Int64? // 可选，数据库自增主键
    let result: String
    let score: Int
    let revisions: [String] // 假设 revisions 是字符串数组，如有更复杂结构请补充
    let review: String
    let simpleReplay: String?
    let formalReplay: String?

}
extension ConversationAnswer {
    // MARK: - GRDB Table
    static let databaseTableName = "conversationAnswer"

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case result
        case score
        case revisions
        case review
        case simpleReplay = "simple_replay"
        case formalReplay = "formal_replay"
    }

    func encode(to container: inout PersistenceContainer) {
        container[Column("id")] = id
        container[Column("result")] = result
        container[Column("score")] = score
        do {
            let stringifiedRevisions = try JSONEncoder().encode(revisions)
            container[Column("revisions")] = stringifiedRevisions
        } catch {
            print("Error encoding revisions: \(error)")
        }
        container[Column("review")] = review
        container[Column("simpleReplay")] = simpleReplay
        container[Column("formalReplay")] = formalReplay
    }

    init(row: Row) throws {
        id = row[Column("id")]
        result = row[Column("result")]
        score = row[Column("score")]
        revisions = try JSONDecoder().decode([String].self, from: row[Column("revisions")])
        review = row[Column("review")]
        simpleReplay = row[Column("simpleReplay")]
        formalReplay = row[Column("formalReplay")]
    }
}

struct AITeacherConversation: Equatable, Identifiable, TableRecord, Codable {

    let documentId: String
    let id: Int
    let updatedAt: Date
    let query: String
    var answer: ConversationAnswer?
    let message_id: String?
    let conversation_id: String?
    var ai_teacher: AITeacher
    var user: UserProfile
    let createdAt: Date
    let publishedAt: Date
    
    let ai_teacher_id: String?
    let user_id: String?
    
    enum Columns{
        static let documentId = Column("documentId")
        static let id = Column("id")
        static let updatedAt = Column("updatedAt")
        static let query = Column("query")
        static let message_id = Column("message_id")
        static let conversation_id = Column("conversation_id")
        static let createdAt = Column("createdAt")
        static let publishedAt = Column("publishedAt")
    }
}

extension AITeacherConversation {
    static var databaseTableName = "aiTeacherHistory"

    func encode(to container: inout PersistenceContainer) {
        container[Column("documentId")] = documentId
        container[Column("id")] = id
        container[Column("updatedAt")] = updatedAt
        container[Column("query")] = query
        container[Column("message_id")] = message_id
        container[Column("conversation_id")] = conversation_id
        container[Column("ai_teacher_id")] = ai_teacher.id
        container[Column("user_id")] = user.id
        container[Column("createdAt")] = createdAt
        container[Column("publishedAt")] = publishedAt
    }
    
    func toChatLatestMessage() -> [ExyteChat.Message] {
        let userMsg =  ExyteChat.Message(
            id: UUID().uuidString,
            user: user.toChatUser(),
            status: .read,
            createdAt: createdAt,
            text: query,
            attachments: [],
            reactions: [],
            recording: nil,
            replyMessage: nil
        )
        if let answer = answer {

            let answerMsg = toAnswerMessage()
            return [userMsg, answerMsg]
        }

        return [userMsg]
    }

    func toChatMessage() -> [ExyteChat.Message] {

        if let answer = answer {
            let userMsg = ExyteChat.Message(
               id: UUID().uuidString,
               user: user.toChatUser(),
               status: .read,
               createdAt: createdAt,
               text: query,
               attachments: [],
               reactions: [],
               recording: nil,
               replyMessage: nil
           )
            let answerMsg = ExyteChat.Message(
                id: message_id ?? UUID().uuidString,
                user: ai_teacher.toChatUser(),
                status: .read,
                createdAt: updatedAt,
                text: answer.result,
                attachments: [],
                reactions: [],
                recording: nil,
                replyMessage: nil
            )
            return [userMsg, answerMsg]
        } else {
            let userMsg = ExyteChat.Message(
               id: UUID().uuidString,
               user: user.toChatUser(),
               status: .sent,
               createdAt: createdAt,
               text: query,
               attachments: [],
               reactions: [],
               recording: nil,
               replyMessage: nil
           )
            return [userMsg]
        }

    }

    func toAnswerMessage() -> ExyteChat.Message {
        var associations: [ExyteChat.Association] = []

        if let simpleReplay = answer?.simpleReplay {
            let association = ExyteChat.Association(
                id: UUID().uuidString,
                type: .suggestion("简单: \(simpleReplay)")
            )
            associations.append(association)
        }

        if let formalReplay = answer?.formalReplay {

            let association = ExyteChat.Association(
                id: UUID().uuidString,
                type: .suggestion("地道: \(formalReplay)")
            )
            associations.append(association)
        }
        let answerMsg = ExyteChat.Message(
            id: message_id ?? UUID().uuidString,
            user: ai_teacher.toChatUser(),
            status: .read,
            createdAt: updatedAt,
            text: answer!.result,
            attachments: [],
            associations: associations,
            recording: nil,
            replyMessage: nil
        )
        return answerMsg
    }

    static var sample: [AITeacherConversation] = [
        AITeacherConversation(
            documentId: "conversation_doc_1",
            id: 1,
            updatedAt: Date(),
            query: "What is the capital of France?",
            answer: ConversationAnswer(result: "The capital of France is Paris.",
                                       score: 100,
                                       revisions: [],
                                       review: "Correct answer.",
                                       simpleReplay: "Got it.",
                                       formalReplay: "Understood."),
            message_id: "message_id_1",
            conversation_id: "conversation_id_1",
            ai_teacher: AITeacher.sample[0],
            user: UserProfile.sample,
            createdAt: Date(),
            publishedAt: Date(),
            ai_teacher_id: AITeacher.sample[0].documentId,
            user_id: UserProfile.sample.documentId
        )
    ]
}
