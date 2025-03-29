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
                category: "men's clothing",
                imageString: "tshirt"
            ),
            .init(
                id: 2,
                title: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
                description: "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
                category: "men's clothing",
                imageString: "bag"
            ),
            .init(
                id: 3,
                title: "Mens Cotton Jacket",
                description: "Great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions, such as working, hiking, camping, mountain/rock climbing, cycling, traveling or other outdoors. Good gift choice for you or your family member. A warm hearted love to Father, husband or son in this thanksgiving or Christmas Day.",
                category: "men's clothing",
                imageString: "jacket"
            )
        ]
    }
}
