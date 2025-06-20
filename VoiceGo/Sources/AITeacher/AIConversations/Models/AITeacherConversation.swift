import Foundation
import GRDB
import SharingGRDB
import ExyteChat

struct ConversationReaction
{
    let emoji: String
    let usedAt : Date
}

extension ConversationReaction: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case emoji
        case usedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emoji = try container.decode(String.self, forKey: .emoji)
        let usedAtString = try container.decode(String.self, forKey: .usedAt)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        usedAt = isoFormatter.date(from: usedAtString) ?? Date()
    }
}

extension ConversationReaction : DatabaseValueConvertible {
    var databaseValue: DatabaseValue {
        let jsonData = try? JSONEncoder().encode(self)
        let stringifiedReaction: String = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
        return stringifiedReaction.databaseValue
    }
    
    static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        guard let stringValue = String.fromDatabaseValue(dbValue) else { return nil }
        guard let jsonData = stringValue.data(using: .utf8) else { return nil }
        guard let conversationReaction = try? JSONDecoder().decode(ConversationReaction.self, from: jsonData) else { return nil }
        return conversationReaction
    }
}

extension ExyteChat.Reaction {
    func toConversationReaction() -> ConversationReaction? {
        switch self.type {
        case .emoji(let emoji):
            return ConversationReaction(emoji: emoji, usedAt: self.createdAt)
        case .menu(_, _):
            return nil
        }
    }
}


struct ConversationAnswer: Codable, FetchableRecord, PersistableRecord, Equatable, Identifiable {
    // 数据库主键（如无可自增，或可用UUID）
    var id: Int64? // 可选，数据库自增主键
    let answer: String
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
        case answer
        case score
        case revisions
        case review
        case simpleReplay = "simple_replay"
        case formalReplay = "formal_replay"
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Column("id")] = id
        container[Column("answer")] = answer
        container[Column("score")] = score
        do {
            let jsonData = try JSONEncoder().encode(revisions)
            let stringifiedRevisions:String = String(data: jsonData, encoding: .utf8) ?? "[]"
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
        answer = row[Column("answer")]
        score = row[Column("score")]
        let stringifiedRevisions = row[Column("revisions")] as String
        guard let jsonData = stringifiedRevisions.data(using: .utf8) else {
            throw DatabaseError(resultCode: .SQLITE_MISUSE, message: "Failed to convert revisions string to data")
        }
        revisions = try JSONDecoder().decode([String].self, from: jsonData)
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
    let reactions: [ConversationReaction]?
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
        static let reactions = Column("reactions")
    }
    
    enum UserMessageActionSystemImage : String, Codable {
        case score = "suit.heart"
        case review = "exclamationmark.triangle"
    }
}

extension AITeacherConversation {
    static var databaseTableName = "aiTeacherHistory"
    
    func toChatLatestMessage() -> [ExyteChat.Message] {
        let userMsg =  toUserMessage()
        if let answer = answer {
            
            let answerMsg = toAnswerMessage()
            return [userMsg, answerMsg]
        }
        
        return [userMsg]
    }
    
    func toChatMessage() -> [ExyteChat.Message] {
        
        if let answer = answer {
            let userMsg = toUserMessage()
            let answerMsg = ExyteChat.Message(
                id: message_id ?? UUID().uuidString,
                user: ai_teacher.toChatUser(),
                status: .read,
                createdAt: updatedAt,
                text: answer.answer,
                attachments: [],
                reactions: [],
                additionMessages: [],
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
        var chatReactions: [ExyteChat.Reaction] = []
        if let reactions = reactions {
            chatReactions = reactions.map { reaction in
                ExyteChat.Reaction(
                    id: UUID().uuidString,
                    user: user.toChatUser(),
                    createdAt: reaction.usedAt,
                    type: .emoji(reaction.emoji),
                    status: .read
                )
            }
        }
        let answerMsg = ExyteChat.Message(
            id: message_id ?? UUID().uuidString,
            user: ai_teacher.toChatUser(),
            status: .read,
            createdAt: updatedAt,
            text: answer!.answer,
            attachments: [],
            reactions: chatReactions,
            associations: associations,
            recording: nil,
            replyMessage: nil
        )
        return answerMsg
    }
    
    func toUserMessage() -> ExyteChat.Message {
        var reactions: [ExyteChat.Reaction] = []
        if let answer = answer {
            let scoreReaction =   ExyteChat.Reaction(
                id: UUID().uuidString,
                user: user.toChatUser(),
                createdAt: updatedAt,
                type: .menu(title: "地道:\(answer.score)", icon: UserMessageActionSystemImage.score.rawValue),
                payload: String(answer.score), status: .read // Assuming score is a string representation
            )
            reactions.append(scoreReaction)
            if answer.revisions.count > 0 {
                let jsonData = try? JSONEncoder().encode(answer.revisions)
                let revisionsString: String = String(data: jsonData ?? Data(), encoding: .utf8) ?? "[]"
                let reviewReaction =   ExyteChat.Reaction(
                    id: UUID().uuidString,
                    user: user.toChatUser(),
                    createdAt: updatedAt,
                    type: .menu(title: "改进:\(answer.revisions.count)", icon:UserMessageActionSystemImage.review.rawValue),
                    payload: revisionsString,
                    status: .read
                )
                reactions.append(reviewReaction)
            }
        }
        
        let userMsg = ExyteChat.Message(
            id: UUID().uuidString,
            user: user.toChatUser(),
            status: .read,
            createdAt: createdAt,
            text: query,
            attachments: [],
            reactions: reactions,
            additionMessages: [],
            recording: nil,
            replyMessage: nil
        )
        return userMsg
    }
    
    static var sample: [AITeacherConversation] = [
        AITeacherConversation(
            documentId: "conversation_doc_1",
            id: 1,
            updatedAt: Date(),
            query: "What is the capital of France?",
            answer: ConversationAnswer(answer: "The capital of France is Paris.",
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
            reactions: [ConversationReaction(emoji: "👍", usedAt: Date())],
            ai_teacher_id: AITeacher.sample[0].documentId,
            user_id: UserProfile.sample.documentId
        )
    ]
}
