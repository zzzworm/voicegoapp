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
    let category: String // Update to enum
    let imageString: String
    
    // Add rating later...
}

extension StudyTool: Decodable {
    private enum StudyToolKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StudyToolKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.category = try container.decode(String.self, forKey: .category)
        self.imageString = try container.decode(String.self, forKey: .image)
    }
}

extension StudyTool {
    static var sample: [StudyTool] {
        [
            .init(
                id: 1,
                title: "AI翻译",
                description: "支持中文翻译",
                category: "翻译",
                imageString: "tshirt"
            ),
            .init(
                id: 2,
                title: "单词记忆助手",
                description: "单词记忆助手",
                category: "单词记忆",
                imageString: "bag"
            ),
            .init(
                id: 3,
                title: "AI润色",
                description: "AI润色",
                category: "AI润色",
                imageString: "jacket"
            ),
            .init(
                id: 4,
                title: "知识百科",
                description: "知识百科",
                category: "知识百科",
                imageString: "jacket"
            )
        ]
    }
}
