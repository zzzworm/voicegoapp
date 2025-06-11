//
//  UserProfile.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import SharingGRDB
import Copyable
import ExyteChat

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
    
    let study_setting : UserStudySetting?
    var studySettingId: Int? = nil

    var displayIdenifier : String? {
        return phoneNumber ?? email
    }
    
}

extension UserProfile: Codable, EncodableRecord, TableRecord {
    
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
        case study_setting
    }

    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["documentId"] = documentId
        container["email"] = email
        container["city"] = city
        container["username"] = username
        container["sex"] = sex.rawValue
        container["provider"] = provider
        container["phoneNumber"] = phoneNumber
        container["userIconUrl"] = userIconUrl
        container["studySettingId"] = studySettingId
    }

    enum Columns {
        static let id = Column(ProfileKeys.id)
        static let documentId = Column(ProfileKeys.documentId)
        static let email = Column(ProfileKeys.email)
        static let city = Column(ProfileKeys.city)
        static let username = Column(ProfileKeys.username)
        static let sex = Column(ProfileKeys.sex)
        static let provider = Column(ProfileKeys.provider)
        static let phoneNumber = Column(ProfileKeys.phoneNumber)
        static let userIconUrl = Column(ProfileKeys.userIconUrl)
        static let studySettingId = Column("studySettingId")
    }
}

extension UserProfile {
    
    func toChatUser() -> ExyteChat.User {
        let avatarURL = URL(string: userIconUrl ?? "")
        return ExyteChat.User(id: documentId, name: username, avatarURL: avatarURL, isCurrentUser: true)
    }
    
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
            userIconUrl: "https://example.com/icon.png",
            study_setting: UserStudySetting.sample
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
            userIconUrl: "https://example.com/icon.png",
            study_setting: UserStudySetting.sample
        )
    }
}

