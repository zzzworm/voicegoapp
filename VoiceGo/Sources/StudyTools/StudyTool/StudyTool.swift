//
//  StudyTool.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture
import SharingGRDB

struct StudyTool: Equatable, Identifiable , FetchableRecord, MutablePersistableRecord {
    
    static let databaseTableName = "studyTool"
    
    let id: Int
    let documentId: String
    let title: String
    let description: String
    let categoryKey: String // Update to enum
    let imageUrl: String
    
    // Add rating later...
}

extension StudyTool: Codable {
    private enum StudyToolKeys: String, CodingKey {
        case id
        case documentId
        case title
        case description
        case categoryKey
        case imageUrl
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

struct StudyToolUsed: Equatable, Identifiable , FetchableRecord, MutablePersistableRecord {
    
    static let databaseTableName = "studyToolUsed"
    let studyToolDocumentId : String
    let id: Int
    let documentId: String
    let lastUsedAt: Date
    let userDocumentId : String
    
}


extension StudyToolUsed: Codable {
    public enum StudyToolUsedKeys: String, CodingKey {
        case id
        case documentId
        case lastUsedAt
    }

}
