//
//  StudyTool.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct StudyTool: Equatable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let categoryKey: String // Update to enum
    let imageUrl: String
    
    // Add rating later...
}

extension StudyTool: Decodable {
    private enum StudyToolKeys: String, CodingKey {
        case id
        case title
        case description
        case categoryKey
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StudyToolKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.categoryKey = try container.decode(String.self, forKey: .categoryKey)
        self.imageUrl = try container.decode(String.self, forKey: .image)
    }
}

extension StudyTool {
    static var sample: [StudyTool] {
        [
            .init(
                id: 1,
                title: "AI翻译",
                description: "支持中文翻译",
                categoryKey: "AI翻译",
                imageUrl: "https://voicego-image.oss-cn-shanghai.aliyuncs.com/images/ai_translation_e2c2ee1941.jpg"
            ),
            .init(
                id: 2,
                title: "单词记忆助手",
                description: "单词记忆助手",
                categoryKey: "单词记忆",
                imageUrl: "bag"
            ),
            .init(
                id: 3,
                title: "AI润色",
                description: "AI润色",
                categoryKey: "AI润色",
                imageUrl: "jacket"
            ),
            .init(
                id: 4,
                title: "知识百科",
                description: "知识百科",
                categoryKey: "知识百科",
                imageUrl: "jacket"
            )
        ]
    }
}
