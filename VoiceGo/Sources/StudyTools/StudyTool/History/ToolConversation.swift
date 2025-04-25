//
//  StudyToolHistory.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//
import Foundation
import GRDB
import SharingGRDB


struct ToolConversation : Equatable, Identifiable,TableRecord  {
    static var databaseTableName = "toolHistory"
    let documentId: String
    let id : Int
    let updatedAt: Date
    let query : String
    var answer : String = ""
    let message_id: String
    let conversation_id: String
    var StudyToolUsed: StudyToolUsed? = nil
}


extension ToolConversation: Codable  , FetchableRecord, MutablePersistableRecord {
    
    func encode(to container: inout PersistenceContainer) throws {
        container[Columns.documentId] = documentId
        container[Columns.id] = id
        container[Columns.updatedAt] = updatedAt
        container[Columns.query] = query
        container[Columns.answer] = answer
        container[Columns.message_id] = message_id
        container[Columns.conversation_id] = conversation_id
    }
    
    enum Columns{
        static let documentId = Column("documentId")
        static let id = Column("id")
        static let updatedAt = Column("updatedAt")
        static let query = Column("query")
        static let answer = Column("answer")
        static let message_id = Column("message_id")
        static let conversation_id = Column("conversation_id")
    }
}

extension ToolConversation {
    static var sample: [ToolConversation] {
        [
            .init(
                documentId: "89fc7a46-4ef5-4250-a6a0-07293a3c7056",
                id: 1,
                updatedAt: Date(),
                query: "apply",
                answer: """
                1. **单词类型及释义**
                    -动词
                        -申请：I want to apply for a new job.（我想要申请一份新工作。）
                        -应用；运用：We should apply this theory to practice.（我们应该把这个理论应用到实践中。）
                        -涂；敷：Apply some cream on your face.（在你的脸上涂一些面霜。）
                2. **时态**：apply的第三人称单数形式为applies，现在分词为applying，过去式和过去分词均为applied。例如：He applies for the scholarship every year.（一般现在时）；She is applying for a visa.（现在进行时）；They applied for the project last month.（一般过去时）
                3. **音标**：[əˈplaɪ]
                4. **音节拆分**：ap -ply，音标拆分：[ə] -[ˈplaɪ]
                5. **记忆方法**：可以根据词缀来记忆。“ap -”可看作是ad -的变体，表示“去，朝向”，“ply”有“折叠；弯曲”的意思，朝着某个方向弯曲（自己以适应要求等），就有了“申请”“应用”等含义。
                """,
                message_id: "89fc7a46-4ef5-4250-a6a0-07293a3c7056",
                conversation_id: "89fc7a46-4ef5-4250-a6a0-07293a3c7056"
            ),
            .init(
                documentId: "89fc7a46-4ef5-4250-a6a0-07293a3c7056",
                id: 1,
                updatedAt: Date(),
                query: "apply",
                answer: """
                单词类型及释义

                动词
                #in: Please wait for a moment.（请稍等片刻。）
                等待；延迟：We have to wait for the results.（我们必须等待结果。）
                → EX: I can't wait to see you!（我迫不及待想见你！）
                时态：

                wait的第三人称单数形式为waits，现在分词为waiting，过去式和过去分词均为waited。
                例：He waits for the bus every morning.（一般现在时）
                She is waiting for her friend.（现在进行时）
                They waited for two hours yesterday.（一般过去时）
                音标：/weɪt/

                音节拆分：wait为一个音节，音节拆分：wait。
                """,
                message_id: "89fc7a46-4ef5-4250-a6a0-07293a3c7056",
                conversation_id: "89fc7a46-4ef5-4250-a6a0-07293a3c7056"
            ),
            
        ]
    }
}
