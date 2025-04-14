//
//  UserProfile.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation

struct UserProfile: Equatable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let icon: String
    
    var name: String {
        "\(lastName)\(firstName) "
    }
}

extension UserProfile: Decodable {
    private enum ProfileKeys: String, CodingKey {
        case id
        case email
        case name
        case firstname
        case lastname
        case phoneName
        case icon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProfileKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        
        let nameContainer = try container.nestedContainer(keyedBy: ProfileKeys.self, forKey: .name)
        self.firstName = try nameContainer.decode(String.self, forKey: .firstname)
        self.lastName = try nameContainer.decode(String.self, forKey: .lastname)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneName)
        self.icon = try container.decode(String.self, forKey: .icon)
    }
}

extension UserProfile {
    static var sample: UserProfile {
        .init(
            id: 1,
            email: "hello@demo.com",
            firstName: "Changhong",
            lastName: "Zhou",
            phoneNumber: "15618664527",
            icon: "https://example.com/icon.png"
        )
    }
    
    static var `default`: UserProfile {
        .init(
            id: 0,
            email: "tophu1@163.com",
            firstName: "changhong",
            lastName: "Zhou",
            phoneNumber: "15618664527",
            icon: "https://example.com/icon.png"
        )
    }
}
