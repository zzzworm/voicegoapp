//
//  InnerAIToolsClient.swift
//  VoiceGo
//
//  Created by admin on 2025/6/17.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//


import Foundation
import Dependencies
import StrapiSwift



struct InnerAIToolsClient {
    var translate: (String) async throws -> String
}

extension DependencyValues {
    var aiToolsClient: InnerAIToolsClient {
        get { self[InnerAIToolsClient.self] }
        set { self[InnerAIToolsClient.self] = newValue }
    }
}

extension InnerAIToolsClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            translate:  { text in
                @Dependency(\.apiClient) var apiClient
                let createToolConversation = StudyTool.translation
                do {
                    let response = try await apiClient.createToolConversation(createToolConversation, text, "")
                    if let answer = response.data.answer {
                        return answer.answer
                    } else {
                        throw NSError(domain: "InnerAIToolsClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Translation failed"])
                    }
                } catch {
                    throw NSError(domain: "InnerAIToolsClientError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response from translation tool"])
                }
            }
        )
    }()
}

extension InnerAIToolsClient: TestDependencyKey {
    static let testValue = Self(
        translate: unimplemented("\(Self.self).translate")
    )
}
