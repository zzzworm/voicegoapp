//
//  StudyTool.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture
import SharingGRDB
import GRDB

struct StudyTool: Equatable, Identifiable, Codable,TableRecord, Sendable {
    
    static let databaseTableName = "studyTool"
    
    let id: Int
    let documentId: String
    let title: String
    let description: String
    let categoryKey: String // Update to enum
    let imageUrl: String
    var exampleCard : QACard? = nil
    var cardDocumentId: String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case documentId
        case title
        case description
        case categoryKey
        case imageUrl
        case exampleCard
    }
    
}

extension StudyTool: FetchableRecord, MutablePersistableRecord, EncodableRecord {
    

    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["documentId"] = documentId
        container["title"] = title
        container["description"] = description
        container["categoryKey"] = categoryKey
        container["imageUrl"] = imageUrl
        container["cardDocumentId"] = cardDocumentId
    }
    
    enum Columns {
        static let documentId = Column(CodingKeys.documentId)
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let  description  = Column(CodingKeys.description)
        static let  categoryKey  = Column(CodingKeys.categoryKey)
        static let  imageUrl  = Column(CodingKeys.imageUrl)
        static let  cardDocumentId  = Column("cardDocumentId")
    }
    
    static var databaseSelection: [any SQLSelectable] {

            [.allColumns(excluding: ["exampleCard"])] // NEW!

        }
}

extension StudyTool {
    static var sample: [StudyTool] {
        [
            .init(
                id: 6,
                documentId: "yjyt2zwv7rfscj28ms6npqf5",
                title: "AI翻译",
                description: "支持中文翻译",
                categoryKey: "AI翻译",
                imageUrl: "https://voicego-image.oss-cn-shanghai.aliyuncs.com/images/ai_translation_e2c2ee1941.jpg"
            ),
            .init(
                id: 9,
                documentId: "yc1mhtf6np5eub9oc2a3u0zc",
                title: "单词记忆助手",
                description: "单词记忆助手",
                categoryKey: "单词记忆",
                imageUrl: "bag"
            ),
            .init(
                id: 11,
                documentId: "sddseztemjku7ovve6g5rry9",
                title: "AI润色",
                description: "AI润色",
                categoryKey: "AI润色",
                imageUrl: "jacket"
            )
        ]
    }
}

struct StudyToolUsed: Equatable, Identifiable, Sendable {
    
    static let databaseTableName = "studyToolUsed"
    
    let id: Int
    let documentId: String
    let lastUsedAt: Date
    var userDocumentId : String?
    var studyToolDocumentId : String?
    var studyTool: StudyTool? = nil
    
}


extension StudyToolUsed: Codable , FetchableRecord, MutablePersistableRecord {
    enum CodedingKeys: String, CodingKey {
        case documentId
        case id
        case lastUsedAt
    }
    func encode(to container: inout PersistenceContainer) {
        container[Column("documentId")] = documentId
        container[Column("id")] = id
        container[Column("lastUsedAt")] = lastUsedAt
        container[Column("userDocumentId")] = userDocumentId
        container[Column("studyToolDocumentId")] = studyToolDocumentId
    }
    
    enum Columns {
        static let documentId = Column(CodingKeys.documentId)
        static let id = Column(CodingKeys.id)
        static let lastUsedAt = Column(CodingKeys.lastUsedAt)
        static let userDocumentId = Column("userDocumentId")
        static let studyToolDocumentId = Column("studyToolDocumentId")
    }

}


extension StudyToolUsed {
    static var sample: [StudyToolUsed] {
        [
            .init(
                id: 6,
                documentId: "yjyt2zwv7rfscj28ms6npqf5",
                lastUsedAt: Date(),
                userDocumentId: "user1",
                studyToolDocumentId: "yjyt2zwv7rfscj28ms6npqf5",
                studyTool:.init(
                id: 6,
                documentId: "yjyt2zwv7rfscj28ms6npqf5",
                title: "AI翻译",
                description: "支持中文翻译",
                categoryKey: "AI翻译",
                imageUrl: "https://voicego-image.oss-cn-shanghai.aliyuncs.com/images/ai_translation_e2c2ee1941.jpg"
                )
            ),
            .init(
                id: 7,
                documentId: "yjyt2zwv7rfscj28ms6npqf5",
                lastUsedAt: Date(),
                userDocumentId: "user1",
                studyToolDocumentId: "yjyt2zwv7rfscj28ms6npqf5",
                studyTool:.init(
                id: 11,
                documentId: "sddseztemjku7ovve6g5rry9",
                title: "AI润色",
                description: "AI润色",
                categoryKey: "AI润色",
                imageUrl: "jacket"
                )
            )
        ]
    }
}
