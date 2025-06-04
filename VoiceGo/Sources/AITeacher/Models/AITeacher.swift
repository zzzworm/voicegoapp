import Foundation
import GRDB

// MARK: - AITeacherCard
struct AITeacherCard: Codable, FetchableRecord, PersistableRecord, Equatable {
    let id: Int
    let openingSpeech: String?
    let simpleReplay: String?
    let formalReplay: String?
    let openingLetter: String?
    let assistContent: String?
    let categoryKey: String?
}

extension AITeacherCard: TableRecord {
    // 数据库表名（如需单独表可设置，否则可省略）
    static var databaseTableName: String { "aiTeacherCard" }

    enum CodingKeys: String, CodingKey {
        case id
        case openingSpeech = "opening_speech"
        case simpleReplay = "simple_replay"
        case formalReplay = "formal_replay"
        case openingLetter = "opening_letter"
        case assistContent = "assist_content"
        case categoryKey 
    }

    func encode(to container: inout PersistenceContainer) {
        container[Column("id")] = id
        container[Column("openingSpeech")] = openingSpeech
        container[Column("simpleReplay")] = simpleReplay
        container[Column("formalReplay")] = formalReplay
        container[Column("openingLetter")] = openingLetter
        container[Column("assistContent")] = assistContent
        container[Column("categoryKey")] = categoryKey
    }

    enum Columns{
        static let id = Column(CodingKeys.id)
        static let openingSpeech = Column(CodingKeys.openingSpeech)
        static let simpleReplay = Column(CodingKeys.simpleReplay)
        static let formalReplay = Column(CodingKeys.formalReplay)
        static let openingLetter = Column(CodingKeys.openingLetter)
        static let assistContent = Column(CodingKeys.assistContent)
        static let categoryKey = Column(CodingKeys.categoryKey)
    }
}

// MARK: - AITeacher
struct AITeacher: Codable, FetchableRecord, PersistableRecord, Equatable, Identifiable {
    let id: Int
    let documentId: String
    let name: String
    let introduce: String
    let createdAt: Date
    let updatedAt: Date
    let publishedAt: Date?
    let sex: String
    let difficultyLevel: Int
    let tags: String
    let card: AITeacherCard?
    var cardId : Int? = nil
}
extension AITeacher: TableRecord {
    static var databaseTableName: String { "aiTeacher" }

    enum CodingKeys: String, CodingKey {
        case id
        case documentId
        case name
        case introduce
        case createdAt
        case updatedAt
        case publishedAt
        case sex
        case difficultyLevel = "difficulty_level"
        case tags
        case card
    }

    func encode(to container: inout PersistenceContainer) {
        container[Column("id")] = id
        container[Column("documentId")] = documentId
        container[Column("name")] = name
        container[Column("introduce")] = introduce
        container[Column("createdAt")] = createdAt
        container[Column("updatedAt")] = updatedAt
        container[Column("publishedAt")] = publishedAt
        container[Column("sex")] = sex
        container[Column("difficultyLevel")] = difficultyLevel
        container[Column("tags")] = tags
        container[Column("cardId")] = cardId
    }

    enum Columns{
        static let id = Column(CodingKeys.id)
        static let documentId = Column(CodingKeys.documentId)
        static let name = Column(CodingKeys.name)
        static let introduce = Column(CodingKeys.introduce)
        static let createdAt = Column(CodingKeys.createdAt)
        static let updatedAt = Column(CodingKeys.updatedAt)
        static let publishedAt = Column(CodingKeys.publishedAt)
        static let sex = Column(CodingKeys.sex)
        static let difficultyLevel = Column(CodingKeys.difficultyLevel)
        static let tags = Column(CodingKeys.tags)
        static let cardId = Column("cardId")
    }
}