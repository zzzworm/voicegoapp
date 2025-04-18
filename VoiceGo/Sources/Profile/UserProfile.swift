//
//  UserProfile.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation

struct UserProfile: Equatable {
    let id : Int
    let documentId: String
    let email: String
    let username: String
    let provider : String
    let phoneNumber: String
    let userIconUrl: String
    
}

extension UserProfile: Decodable {
    private enum ProfileKeys: String, CodingKey {
        case id
        case documentId
        case email
        case name
        case provider
        case username
        case phoneName
        case userIconUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProfileKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.documentId = try container.decode(String.self, forKey: .documentId)
        self.email = try container.decode(String.self, forKey: .email)
        self.provider = try container.decode(String.self, forKey: .provider)
        self.username = try container.decode(String.self, forKey: .username)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneName)
        self.userIconUrl = try container.decode(String.self, forKey: .userIconUrl)
    }
}

extension UserProfile {
    static var sample: UserProfile {
        .init(
            id: 1,
            documentId: "",
            email: "hello@demo.com",
            username: "Changhong",
            provider: "local",
            phoneNumber: "15618664527",
            userIconUrl: "https://example.com/icon.png"
        )
    }
    
    static var `default`: UserProfile {
        .init(
            id: 0,
            documentId: "",
            email: "tophu1@163.com",
            username: "changhong",
            provider: "local",
            phoneNumber: "15618664527",
            userIconUrl: "https://example.com/icon.png"
        )
    }
}
