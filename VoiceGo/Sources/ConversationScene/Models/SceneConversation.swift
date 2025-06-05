import Foundation
import GRDB
import SharingGRDB


struct SceneConversation : Equatable, Identifiable,TableRecord, Codable  {

    let documentId: String
    let id : Int
    let updatedAt: Date
    let query : String
    var answer : ConversationAnswer
    let message_id: String
    let conversation_id: String
    var scene: ConversationScene? = nil
}

extension SceneConversation {
        static var databaseTableName = "SceneHistory"
}
