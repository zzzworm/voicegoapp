//
//  QACard.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/22.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import SharingGRDB
import GRDB
import Foundation

struct QACard : Equatable, Codable {
    
    static let databaseTableName = "studyToolCard"
    let id: Int
    var isExample : Bool = true
    var originCaption : String = "原文"
    var originText : String = ""
    var actionText : String = ""
    var suggestions: [String] = []
    private var suggestionText : String {
        get {suggestions.joined(separator: "|!")}
        set {suggestions = newValue.components(separatedBy: "|!")}
    }
}

extension QACard : TableRecord ,FetchableRecord, MutablePersistableRecord
{
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let isExample = Column(CodingKeys.isExample)
        static let originCaption = Column(CodingKeys.originCaption)
        static let originText = Column(CodingKeys.originText)
        static let actionText = Column(CodingKeys.actionText)
        static let suggestionText = Column(CodingKeys.suggestions)
    }
}
