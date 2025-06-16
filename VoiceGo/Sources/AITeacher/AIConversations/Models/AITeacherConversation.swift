import Foundation
import GRDB
import SharingGRDB
import ExyteChat


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
}

struct AITeacherConversation : Equatable, Identifiable,TableRecord, Codable  {

    let documentId: String
    let id : Int
    let updatedAt: Date
    let query : String
    var answer : ConversationAnswer?
    let message_id: String?
    let conversation_id: String?
    var ai_teacher: AITeacher
    var user: UserProfile
    let createdAt: Date
    let publishedAt: Date
}

extension AITeacherConversation {
    static var databaseTableName = "aiTeacherHistory"
    
    func toChatLatestMessage() -> [ExyteChat.Message] {
        let userMsg =  ExyteChat.Message(
            id: UUID().uuidString,
            user: user.toChatUser(),
            status: .read,
            createdAt: createdAt,
            text: query,
            attachments:[],
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
               attachments:[],
               reactions: [],
               recording: nil,
               replyMessage: nil
           )
            let answerMsg = ExyteChat.Message(
                id: message_id ?? UUID().uuidString,
                user: ai_teacher.toChatUser(),
                status: .read,
                createdAt: updatedAt,
                text: answer.answer,
                attachments: [],
                reactions: [],
                recording: nil,
                replyMessage: nil
            )
            return [userMsg, answerMsg]
        }
        else{
            let userMsg = ExyteChat.Message(
               id: UUID().uuidString,
               user: user.toChatUser(),
               status: .sent,
               createdAt: createdAt,
               text: query,
               attachments:[],
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
            text: answer!.answer,
            attachments: [],
            associations: associations,
            recording: nil,
            replyMessage: nil
        )
        return answerMsg
    }
    
    static var sample : [AITeacherConversation] = [
        AITeacherConversation(
            documentId: "conversation_doc_1",
            id: 1,
            updatedAt: Date(),
            query: "What is the capital of France?",
            answer: ConversationAnswer(answer: "The capital of France is Paris.", score: 100, revisions: [], review: "Correct answer.", simpleReplay: "Got it.", formalReplay: "Understood."),
            message_id: "message_id_1",
            conversation_id: "conversation_id_1",
            ai_teacher: AITeacher.sample[0],
            user: UserProfile.sample,
            createdAt: Date(),
            publishedAt: Date()
        )
    ]
}

