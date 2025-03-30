//
//  StringExtended.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/30.
//

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
