import Foundation
import Copyable
import SharingGRDB
import GRDB

@Copyable
struct UserStudySetting : Identifiable, Equatable , Sendable  {
    
    enum EngLevel : String, CaseIterable, Codable, Equatable {
        case primary = "primary"
        case intermediate = "intermediate"
        case advanced = "advanced"
        case professional = "professional"
        
        var localizedDescription: String {
            switch self {
            case .primary:
                return String(localized: "Primary", comment: "Eng level: Primary")
            case .intermediate:
                return String(localized: "Intermediate", comment: "Eng level: Intermediate")
            case .advanced:
                return String(localized: "Advanced", comment: "Eng level: Advanced")
            case .professional:
                return String(localized: "Professional", comment: "Eng level: Professional")
            }
        }
    }

    enum UserRole: String, CaseIterable, Codable, Equatable {
        case schoolStudent = "school_student"
        case collegeStudent = "college_student"
        case internationalStudent = "international_student"
        case employee = "employee"
        case parent = "parent"
        case teacher = "teacher"
        case others = "others"
        
        var localizedDescription: String {
            switch self {
            case .schoolStudent:
                return String(localized: "School Student", comment: "User type: School Student")
            case .collegeStudent:
                return String(localized: "College Student", comment: "User type: College Student")
            case .internationalStudent:
                return String(localized: "International Student", comment: "User type: International Student")
            case .employee:
                return String(localized: "Employee", comment: "User type: Employee")
            case .parent:
                return String(localized: "Parent", comment: "User type: Parent")
            case .teacher:
                return String(localized: "Teacher", comment: "User type: Teacher")
            case .others:
                return String(localized: "Others", comment: "User type: Others")
            }
        }
    }
    
    enum WordLevel: String, CaseIterable, Codable, Equatable {
        case preschool = "preschool"
        case primarySchool = "primary_school"
        case juniorHighSchool = "junior_high_school"
        case seniorHighSchool = "senior_high_school"
        case cet4 = "CET-4"
        case cet6 = "CET-6"
        case postgraduateEntrance = "postgraduate_entrance_examination"
        case business = "business"
        case ielts = "IELTS"
        case toefl = "TOEFL"
        case gre = "GRE"
        case gmat = "GMAT"
        case sat = "SAT"
        case highDifficulty = "high_difficulty"
        
        var localizedDescription: String {
            switch self {
            case .preschool:
                return String(localized: "Preschool", comment: "Word level: Preschool")
            case .primarySchool:
                return String(localized: "Primary School", comment: "Word level: Primary School")
            case .juniorHighSchool:
                return String(localized: "Junior High School", comment: "Word level: Junior High School")
            case .seniorHighSchool:
                return String(localized: "Senior High School", comment: "Word level: Senior High School")
            case .cet4:
                return String(localized: "CET-4", comment: "Word level: College English Test Band 4")
            case .cet6:
                return String(localized: "CET-6", comment: "Word level: College English Test Band 6")
            case .postgraduateEntrance:
                return String(localized: "Postgraduate Entrance Exam", comment: "Word level: Postgraduate Entrance Examination")
            case .business:
                return String(localized: "Business English", comment: "Word level: Business English")
            case .ielts:
                return String(localized: "IELTS", comment: "Word level: International English Language Testing System")
            case .toefl:
                return String(localized: "TOEFL", comment: "Word level: Test of English as a Foreign Language")
            case .gre:
                return String(localized: "GRE", comment: "Word level: Graduate Record Examination")
            case .gmat:
                return String(localized: "GMAT", comment: "Word level: Graduate Management Admission Test")
            case .sat:
                return String(localized: "SAT", comment: "Word level: Scholastic Assessment Test")
            case .highDifficulty:
                return String(localized: "Advanced", comment: "Word level: High Difficulty")
            }
        }
    }
    
    let id: Int
    let eng_level : EngLevel
    let word_level: WordLevel
    let study_goal: String
    let role: UserRole
}

extension UserStudySetting : Codable,  EncodableRecord, MutablePersistableRecord {

    static let databaseTableName = "userStudySetting"
    
    enum CodingKeys: String, CodingKey {
        case id
        case eng_level
        case word_level
        case study_goal
        case role
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let eng_level = Column(CodingKeys.eng_level)
        static let word_level = Column(CodingKeys.word_level)
        static let study_goal = Column(CodingKeys.study_goal)
        static let role = Column(CodingKeys.role)
    }

    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["eng_level"] = eng_level.rawValue
        container["word_level"] = word_level.rawValue
        container["study_goal"] = study_goal
        container["role"] = role.rawValue
    }
}

extension UserStudySetting {
    static var sample: UserStudySetting  = .init(id: 1, eng_level: .primary, word_level:.cet4, study_goal: "Learn English", role: .schoolStudent)
}
