//
//  UserProfile.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import SharingGRDB

struct UserProfile: Identifiable, Equatable , FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "userProfile"

    public enum Sex : String, CaseIterable, Codable {
        case male
        case female
        
        var localizedDescription: String {
            switch self {
            case .male:
                return "男"
            case .female:
                return "女"
            }
        }
    }
    
    let id : Int
    let documentId: String
    let email: String
    let city : String?
    let username: String
    var sex : Sex = .male
    let provider : String
    let phoneNumber: String?
    let userIconUrl: String?
    
    var displayIdenifier : String? {
        return phoneNumber ?? email
    }
    
}

extension UserProfile: Codable, EncodableRecord {
    public enum ProfileKeys: String, CodingKey {
        case id
        case documentId
        case email
        case city
        case username
        case sex
        case provider
        case phoneNumber
        case userIconUrl
    }
    
}

extension UserProfile {
    static var sample: UserProfile {
        .init(
            id: 1,
            documentId: "",
            email: "hello@demo.com",
            city: "Beijing",
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
            city: "Shanghai",
            username: "changhong",
            provider: "local",
            phoneNumber: "15618664527",
            userIconUrl: "https://example.com/icon.png"
        )
    }
}

