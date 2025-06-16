//
//  VoiceGoAPIClient+TestPreview.swift
//  VoiceGo
//
//  Created by AI Assistant on 2025/6/4.
//

import Foundation
import ComposableArchitecture
import StrapiSwift
import Alamofire

extension VoiceGoAPIClient: TestDependencyKey {
    static var testValue = Self(
        fetchStudyTools: { _ in
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)
            let meta = Meta(pagination: pagination)
            let resp = StrapiResponse(
                data: StudyTool.sample,
                meta: meta
            )
            return resp
        },
        fetchUserProfile: {
            let profile = UserProfile.sample
            return profile
        },
        updateUserProfile: { profile in
            return profile // 在测试模式下直接返回传入的 profile
        },
        getAliSTS: {
            return AliOSSSTS(
                accessKeyId: "test-key-id",
                accessKeySecret: "test-key-secret",
                securityToken: "test-token",
                expiration: "2025-05-29T13:57:15Z",
                region: "oss-cn-shanghai",
                bucket: "voicego-image"
            )
        },
        getToolConversationList: { _, _, _ in
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)
            let meta = Meta(pagination: pagination)
            let resp = StrapiResponse(
                data: ToolConversation.sample,
                meta: meta
            )
            return resp
        },
        createToolConversation: { _, _ in
            let response = StrapiResponse(
                data: ToolConversation.sample[0],
                meta: nil
            )
            return response
        },
        streamToolConversation: {studyTool, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId": .string(studyTool.documentId), "categoryKey": .string(studyTool.categoryKey)]), "query": .string(query)])
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)

                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: 503, name: "Service Unavailable", message: errorMessage, details: nil)
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 503, error: errorDetails))
                            }
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    let errorDetails = StrapiErrorDetails(status: httpResponse.statusCode, name: "Bad Request", message: errorMessage, details: nil)
                                    continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, error: errorDetails))
                                } else {
                                    continuation.finish()
                                }

                        }
                    })
                }
            }
        },
        createAITeacherConversation: { _, _ in

            let conversation = AITeacherConversation.sample[0]
            return StrapiResponse(data: conversation, meta: Meta(pagination: Pagination()))
        },
        streamAITeacherConversation: { aiTeacher, query in

            return AsyncThrowingStream { continuation in
                Task {
                    let categoryKey = aiTeacher.card?.categoryKey ?? "教练对话"
                    let assist_content = aiTeacher.card?.assistContent ?? "请根据用户的提问，给出专业的回答"
                    let data = StrapiRequestBody([
                        "ai_teacher": .dictionary([
                            "documentId": .string(aiTeacher.documentId),
                            "categoryKey": .string(categoryKey),
                            "assist_content": .string(assist_content)
                        ]),
                        "query": .string(query)
                    ])
                    let request = try await Strapi.contentManager.collection("teacher-conversation/create-message?stream").asPostRequest(data)
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message: break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: 503, name: "Service Unavailable", message: errorMessage, details: nil)
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 503, error: errorDetails))
                            }
                            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: httpResponse.statusCode, name: "Bad Request", message: errorMessage, details: nil)
                                continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, error: errorDetails))
                            } else {
                                continuation.finish()
                            }
                        }
                    })
                }
            }
        },
        getAITeacherConversationList: { _, _, _ in
            return StrapiResponse(data: [], meta: Meta(pagination: Pagination()))
        },
        loadMoreAITeacherConversationList: { _, _, _ in
            return StrapiResponse(data: [], meta: Meta(pagination: Pagination()))
        },
        fetchAITeachers: {
            let filteredTeachers = AITeacher.sample
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: filteredTeachers.count)
            let meta = Meta(pagination: pagination)
            return StrapiResponse(data: filteredTeachers, meta: meta)
        },
        streamSenceConversation: { scene, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let categoryKey = scene.card?.categoryKey ?? "场景对话"
                    let assist_content = scene.card?.assistContent ?? "请根据用户的提问，给出专业的回答"
                    let data = StrapiRequestBody([
                        "scene": .dictionary([
                            "documentId": .string(scene.documentId),
                            "categoryKey": .string(categoryKey),
                            "assist_content": .string(assist_content)
                        ]),
                        "query": .string(query)
                    ])
                    let request = try await Strapi.contentManager.collection("scene-conversation/create-message?stream").asPostRequest(data)
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message: break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: 503, name: "Service Unavailable", message: errorMessage, details: nil)
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 503, error: errorDetails))
                            }
                            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: httpResponse.statusCode, name: "Bad Request", message: errorMessage, details: nil)
                                continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, error: errorDetails))
                            } else {
                                continuation.finish()
                            }
                        }
                    })
                }
            }
        },
        getSenceConversationList: { sceneId, page, pageSize in
            let pagination = Pagination(page: page, pageSize: pageSize, pageCount: 1, limit: pageSize, start: 0, total: 1)
            let meta = Meta(pagination: pagination)
            let resp = StrapiResponse(
                data: [SceneConversation(
                    documentId: sceneId,
                    id: 1,
                    updatedAt: Date(),
                    query: "preview-scene-query",
                    answer: ConversationAnswer(id: 1,
                                               result: "scene-answer",
                                               score: 1,
                                               revisions: ["scene-revision"],
                                               review: "scene-review",
                                               simpleReplay: "scene-simple",
                                               formalReplay: "scene-formal"),
                    message_id: "scene-message-id",
                    conversation_id: "scene-conv-id",
                    scene: ConversationScene.sample.first
                )],
                meta: meta
            )
            return resp
        },
        fetchSenceList: { categoryRawValue in
            let filteredScenes = ConversationScene.sample.filter { $0.tags.localizedCaseInsensitiveContains(categoryRawValue) }
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: filteredScenes.count)
            let meta = Meta(pagination: pagination)
            return StrapiResponse(data: filteredScenes, meta: meta)
        }
    )
}

extension VoiceGoAPIClient {
    static var previewValue = Self(
        fetchStudyTools: { _ in
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)
            let meta = Meta(pagination: pagination)
            let resp = StrapiResponse(
                data: StudyTool.sample,
                meta: meta
            )
            return resp
        },
        fetchUserProfile: {
            let profile = UserProfile.sample
            return profile
        },
        updateUserProfile: { profile in
            return profile
        },
        getAliSTS: {
            return AliOSSSTS(
                accessKeyId: "test-key-id",
                accessKeySecret: "test-key-secret",
                securityToken: "test-token",
                expiration: "2025-05-29T13:57:15Z",
                region: "oss-cn-shanghai",
                bucket: "voicego-image"
            )
        },
        getToolConversationList: { _, _, _ in
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)
            let meta = Meta(pagination: pagination)
            let resp = StrapiResponse(
                data: ToolConversation.sample,
                meta: meta
            )
            return resp
        },
        createToolConversation: { _, _ in
            let response = StrapiResponse(
                data: ToolConversation.sample[0],
                meta: nil
            )
            return response
        },
        streamToolConversation: { _, _ in
            return AsyncThrowingStream { continuation in
                continuation.finish()
            }
        },
        createAITeacherConversation: { _, _ in
            let conversation = AITeacherConversation.sample[0]
            return StrapiResponse(data: conversation, meta: Meta(pagination: Pagination()))
        },
        streamAITeacherConversation: { aiTeacher, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let categoryKey = aiTeacher.card?.categoryKey ?? "教练对话"
                    let assist_content = aiTeacher.card?.assistContent ?? "请根据用户的提问，给出专业的回答"
                    let data = StrapiRequestBody([
                        "ai_teacher": .dictionary([
                            "documentId": .string(aiTeacher.documentId),
                            "categoryKey": .string(categoryKey),
                            "assist_content": .string(assist_content)
                        ]),
                        "query": .string(query)
                    ])
                    let request = try await Strapi.contentManager.collection("teacher-conversation/create-message?stream").asPostRequest(data)
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message: break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: 503, name: "Service Unavailable", message: errorMessage, details: nil)
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 503, error: errorDetails))
                            }
                            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: httpResponse.statusCode, name: "Bad Request", message: errorMessage, details: nil)
                                continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, error: errorDetails))
                            } else {
                                continuation.finish()
                            }
                        }
                    })
                }
            }
        },
        getAITeacherConversationList: { _, _, _ in
            return StrapiResponse(data: [], meta: Meta(pagination: Pagination()))
        },
        loadMoreAITeacherConversationList: { _, _, _ in
            return StrapiResponse(data: [], meta: Meta(pagination: Pagination()))
        },
        fetchAITeachers: {
            let filteredTeachers = AITeacher.sample
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: filteredTeachers.count)
            let meta = Meta(pagination: pagination)
            return StrapiResponse(data: filteredTeachers, meta: meta)
        },
        streamSenceConversation: { scene, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let categoryKey = scene.card?.categoryKey ?? "场景对话"
                    let assist_content = scene.card?.assistContent ?? "请根据用户的提问，给出专业的回答"
                    let data = StrapiRequestBody([
                        "scene": .dictionary([
                            "documentId": .string(scene.documentId),
                            "categoryKey": .string(categoryKey),
                            "assist_content": .string(assist_content)
                        ]),
                        "query": .string(query)
                    ])
                    let request = try await Strapi.contentManager.collection("scene-conversation/create-message?stream").asPostRequest(data)
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message: break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: 500, name: "Bad Request", message: errorMessage, details: nil)
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 500, error: errorDetails))
                            }
                            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                let errorMessage = "Bad Response"
                                let errorDetails = StrapiErrorDetails(status: 500, name: "Bad Request", message: errorMessage, details: nil)
                                continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, error: errorDetails))
                            } else {
                                continuation.finish()
                            }
                        }
                    })
                }
            }
        },
        getSenceConversationList: { sceneId, page, pageSize in
            let pagination = Pagination(page: page, pageSize: pageSize, pageCount: 1, limit: pageSize, start: 0, total: 1)
            let meta = Meta(pagination: pagination)
            let resp = StrapiResponse(
                data: [SceneConversation(
                    documentId: sceneId,
                    id: 1,
                    updatedAt: Date(),
                    query: "preview-scene-query",
                    answer: ConversationAnswer(id: 1,
                                               result: "scene-answer",
                                               score: 1,
                                               revisions: ["scene-revision"],
                                               review: "scene-review",
                                               simpleReplay: "scene-simple",
                                               formalReplay: "scene-formal"),
                    message_id: "scene-message-id",
                    conversation_id: "scene-conv-id",
                    scene: ConversationScene.sample.first
                )],
                meta: meta
            )
            return resp
        },
        fetchSenceList: { categoryRawValue in
            let filteredScenes = ConversationScene.sample.filter { $0.tags.localizedCaseInsensitiveContains(categoryRawValue) }
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: filteredScenes.count)
            let meta = Meta(pagination: pagination)
            return StrapiResponse(data: filteredScenes, meta: meta)
        }
    )
}
