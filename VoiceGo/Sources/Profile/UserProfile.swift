//
//  UserProfile.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import SharingGRDB
import Copyable


@Copyable
struct UserProfile: Identifiable, Equatable , FetchableRecord, MutablePersistableRecord {

    public enum Sex : String, CaseIterable, Codable, Equatable {
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
    let sex : Sex
    let provider : String
    let phoneNumber: String?
    let userIconUrl: String?
    
    var displayIdenifier : String? {
        return phoneNumber ?? email
    }
    
}

extension UserProfile: Codable, EncodableRecord {
    
    static let databaseTableName = "userProfile"
    
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
            sex: .male,
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
            sex: .female,
            provider: "local",
            phoneNumber: "15618664527",
            userIconUrl: "https://example.com/icon.png"
        )
    }
}

