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
    let coverUrl: String
    let card: AITeacherCard?
    var cardId : Int? = nil

    static var sample: [AITeacher] = [
        AITeacher(
            id: 1,
            documentId: "teacher_doc_1",
            name: "Dr. Emily Carter",
            introduce: "Expert in conversational English and business terminology. Focuses on Business English.",
            createdAt: Date(),
            updatedAt: Date(),
            publishedAt: Date(),
            sex: "female",
            difficultyLevel: 2,
            tags: "Business,Advanced,IELTS",
            coverUrl: "",
            card: AITeacherCard(id: 1,
                                openingSpeech: "Hello! Let's talk business.",
                                simpleReplay: "Got it.",
                                formalReplay: "Understood.",
                                openingLetter: "Dear Student,",
                                assistContent: "We can practice negotiations.",
                                categoryKey: "business"),
            cardId: 1
        ),
        AITeacher(
            id: 2,
            documentId: "teacher_doc_2",
            name: "Mr. John Doe",
            introduce: "Specializes in everyday conversation and travel vocabulary. Your go-to for Travel prep.",
            createdAt: Date(),
            updatedAt: Date(),
            publishedAt: Date(),
            sex: "male",
            difficultyLevel: 1,
            tags: "Travel,Beginner,General",
            coverUrl: "",
            card: AITeacherCard(id: 2,
                                openingSpeech: "Hi there! Planning a trip?",
                                simpleReplay: "Okay.",
                                formalReplay: "Certainly.",
                                openingLetter: "Hi,",
                                assistContent: "Ask me about directions.",
                                categoryKey: "travel"),
            cardId: 2
        ),
        AITeacher(
            id: 3,
            documentId: "teacher_doc_3",
            name: "Prof. Ada Byron",
            introduce: "Focuses on academic discussions and formal presentations. Ideal for Academic English.",
            createdAt: Date(),
            updatedAt: Date(),
            publishedAt: Date(),
            sex: "female",
            difficultyLevel: 3,
            tags: "Academic,Formal,University",
            coverUrl: "",
            card: AITeacherCard(id: 3,
                                openingSpeech: "Greetings. Shall we discuss your research?",
                                simpleReplay: "I see.",
                                formalReplay: "Precisely.",
                                openingLetter: "Dear Scholar,",
                                assistContent: "Let's review your thesis statement.",
                                categoryKey: "academic"),
            cardId: 3
        )
    ]
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
        case coverUrl
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
        container[Column("coverUrl")] = coverUrl
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
        static let coverUrl = Column(CodingKeys.coverUrl)
        static let cardId = Column("cardId")
    }
}

extension AITeacher {
    enum CategoryTag: String, CaseIterable, Identifiable, Equatable {
        case general = "基础对话"
        case business = "Business"
        case travel = "Travel"
        case academic = "Academic"

        var id: String { self.rawValue }

        var localizedDescription: String {
            // In a real app, these would be localized strings
            return self.rawValue
        }

        // A default category
        static var defaultTag: CategoryTag {
            .general
        }
    }
}
