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

struct StudyTool: Equatable, Identifiable, Sendable {
    
    static let databaseTableName = "studyTool"
    
    let id: Int
    let documentId: String
    let title: String
    let description: String
    let categoryKey: String // Update to enum
    let categoryTag: ToolTag
    let imageUrl: String?
    var exampleCard : QACard? = nil
    var cardDocumentId: String? = nil
    
    enum ToolTag: String, CaseIterable, Codable {
        case language_study
        case official_language
        case funny_study
        case role_play
        
        // 返回本地化描述
        var localizedDescription: String {
            switch self {
            case .language_study:
                return String(localized: "ToolTag_language_study", comment: "")
            case .official_language:
                return String(localized: "ToolTag_official_language", comment: "")
            case .funny_study:
                return String(localized: "ToolTag_funny_study", comment: "")
            case .role_play:
                return String(localized: "ToolTag_role_play", comment: "")
            }
        }
    }
    
}

extension StudyTool: Codable, FetchableRecord ,TableRecord, MutablePersistableRecord, EncodableRecord {
    enum CodingKeys: String, CodingKey {
        case id
        case documentId
        case title
        case description
        case categoryKey
        case categoryTag
        case imageUrl
        case exampleCard
    }

    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["documentId"] = documentId
        container["title"] = title
        container["description"] = description
        container["categoryKey"] = categoryKey
        container["categoryTag"] = categoryTag.rawValue
        container["imageUrl"] = imageUrl
        container["cardDocumentId"] = cardDocumentId
    }
    
    enum Columns {
        static let documentId = Column(CodingKeys.documentId)
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let  description  = Column(CodingKeys.description)
        static let  categoryKey  = Column(CodingKeys.categoryKey)
        static let  categoryTag  = Column(CodingKeys.categoryTag)
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
                categoryTag: .language_study,
                imageUrl: "https://voicego-image.oss-cn-shanghai.aliyuncs.com/images/ai_translation_e2c2ee1941.jpg"
            ),
            .init(
                id: 9,
                documentId: "yc1mhtf6np5eub9oc2a3u0zc",
                title: "单词记忆助手",
                description: "单词记忆助手",
                categoryKey: "单词记忆",
                categoryTag: .language_study,
                imageUrl: "bag"
            ),
            .init(
                id: 11,
                documentId: "sddseztemjku7ovve6g5rry9",
                title: "AI润色",
                description: "AI润色",
                categoryKey: "AI润色",
                categoryTag: .language_study,
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


extension StudyToolUsed: Codable ,TableRecord , FetchableRecord, MutablePersistableRecord {
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
                categoryTag: .language_study,
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
                categoryTag: .language_study,
                imageUrl: "https://voicego-image.oss-cn-shanghai.aliyuncs.com/images/memory_word_25f17a5e3e.png"
                )
            )
        ]
    }
}
