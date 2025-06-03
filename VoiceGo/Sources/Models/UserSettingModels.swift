import Foundation
import Copyable
import SharingGRDB
import GRDB

@Copyable
struct UserStudySetting : Identifiable, Equatable , Sendable  {
    
    let id: Int
    let eng_level : String
    let study_goal: String
    let role: String
}

extension UserStudySetting : Codable,  EncodableRecord, MutablePersistableRecord {

    static let databaseTableName = "userStudySetting"
    enum CodingKeys: String, CodingKey {
        case id
        case eng_level
        case study_goal
        case role
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let eng_level = Column(CodingKeys.eng_level)
        static let study_goal = Column(CodingKeys.study_goal)
        static let role = Column(CodingKeys.role)
    }

    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["eng_level"] = eng_level
        container["study_goal"] = study_goal
        container["role"] = role
    }
}

extension UserStudySetting {
    static var sample: UserStudySetting  = .init(id: 1, eng_level: "A1", study_goal: "Learn English", role: "Student")
}
