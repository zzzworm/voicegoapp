//
//  StudySetting.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation

struct StudySetting: Equatable {
    public enum Level: Int {
        case base
        case primary
        case intermediate
        case advanced
        case expert
    }
    let level: Level
    let target: String
    let role: String
    let hobble: String
    let targetLocale: String
}

extension StudySetting: Decodable {
    private enum StudySettingeKeys: String, CodingKey {
        case level
        case target
        case role
        case hobble
        case targetLocale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StudySettingeKeys.self)
        self.level = StudySetting.Level(rawValue: try container.decode(Int.self, forKey: .level)) ?? .primary
        self.target = try container.decode(String.self, forKey: .target)
        self.hobble = try container.decode(String.self, forKey: .hobble)
        self.role = try container.decode(String.self, forKey: .role)
        self.targetLocale = try container.decode(String.self, forKey: .targetLocale)
    }
}

extension StudySetting {
    static var sample: StudySetting {
        .init(
            level: .primary,
            target: "hello@demo.com",
            role: "Changhong",
            hobble: "Zhou",
            targetLocale: "15618664527"
        )
    }
    
    static var `default`: StudySetting {
        .init(
            level: .intermediate,
            target: "",
            role: "",
            hobble: "",
            targetLocale: ""
        )
    }
}
