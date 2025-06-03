//
//  VoiceGoAPIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import SwiftyJSON
import StrapiSwift
import Alamofire


struct VoiceGoAPIClient {
    var fetchStudyTools:  @Sendable (String) async throws -> StrapiResponse<[StudyTool]>
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    var updateUserProfile:  @Sendable (UserProfile) async throws -> UserProfile
    var getAliSTS: @Sendable () async throws -> AliOSSSTS
    
    var getToolConversationList:  @Sendable (_ studyToolId : String ,_ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[ToolConversation]>
    var createToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> StrapiResponse<ToolConversation>
    var streamToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> AsyncThrowingStream<DataStreamRequest.EventSourceEvent, Error>
    struct Failure: Error, Equatable {}
}

func handleStrapiRequest<T: Decodable & Sendable>(_ action: @Sendable () async throws -> StrapiResponse<T>) async rethrows -> StrapiResponse<T> {
    do {
        let response = try await action()
        return response
    } catch {
        switch error {
        case let strapiError as StrapiSwiftError:

                switch strapiError {
                case .badResponse(let statusCode, let message):
                    if statusCode > 400 && statusCode < 500 {
                        @Dependency(\.notificationCenter) var notificationCenter
                        print("Bad response: \(statusCode)")
                        notificationCenter.post(.signOut, nil, nil)
                    }
                    print("Bad response: \(message)")
                case .decodingError(let decodingError):
                    print("Unauthorized")
                case .unknownError(let unknownError):
                    print("Unknown error: \(unknownError)")
                case .noDataAvailable:
                    print("No data available")
                default:
                    print("Strapi Error: \(strapiError)")
                }
            
        default:
            print("request Error: \(error)")
        }
        throw error
    }
}


// 使用Moya实现APIClient的liveValue
extension VoiceGoAPIClient : DependencyKey  {
    
    
    
    static let liveValue = Self(
        fetchStudyTools: { category in
            return try await handleStrapiRequest{
                let resp =  try await Strapi.contentManager.collection("study-tools")
                    .filter("[categoryTag]", operator: .equal, value: category)
                    .populate("exampleCard")
                    .getDocuments(as: [StudyTool].self)
            return resp
        }},
        fetchUserProfile: {
            let response = try await Strapi.authentication.local.me(as: UserProfile.self)
            return response
        },
        updateUserProfile: { profile in
            let data = StrapiRequestBody([
                "username": .string(profile.username),
                "email": .string(profile.email),
                "city": .string(profile.city ?? ""),
                "userIconUrl": .string(profile.userIconUrl ?? "")
            ])
            return try await Strapi.authentication.local.updateProfile(data, userId: profile.id, as: UserProfile.self)
        },
        getAliSTS: {
            let resp = try await Strapi.contentManager.collection("ali-cloud-sts").withDocumentId("").getDocument(as: AliOSSSTS.self)
            return resp.data
        },
        getToolConversationList: {studyToolId, page, pageSize in
            let response = try await Strapi.contentManager.collection("tool-conversation/my-list")
                .filter("[study_tool_user_used][studyTool][documentId]",operator: .equal, value:studyToolId)
                .paginate(page: page, pageSize: pageSize)
                .getDocuments(as: [ToolConversation].self)
            return response
        },
        createToolConversation: {studyTool, query in
            
            let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId)]), "query": .string(query)]);
            let response = try await Strapi.contentManager.collection("tool-conversation").postData(data, as: ToolConversation.self)
            return response
        },
        streamToolConversation: {studyTool, query in
    
            return AsyncThrowingStream() { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
                    
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break;
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                return continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: 503, message: errorMessage))
                            }
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                                }
                                else{
                                    continuation.finish()
                                }
                            
                        }
                    })
                }
            }
        }
    )
}



extension VoiceGoAPIClient {
    static var previewValue = Self(
        fetchStudyTools: { _ in

            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)


            let resp =  StrapiResponse(
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
            return profile // 在预览模式下直接返回传入的 profile
        },
        //临时禁止swift 长度检查规则，否则无法编译
        // swiftlint:disable line_length
        getAliSTS: {
            return AliOSSSTS(
                accessKeyId: "STS.NWqqtfaFDWdTjC4fcPaSbd2Wh",
                accessKeySecret: "3tKGGb5BnjsF6xjindJL7GbycQJ65upz3VNyXAMrAjLn",
                securityToken: "CAIS/QJ1q6Ft5B2yfSjIr5TEOs7SjJll4Ka/aGWFgmMFbdxOi/f8ijz2IHhMeXdoCOkat/4zmWlT5vYYlqZtTJ5OSEPDKNB99Y9W9gX57wh9MVXvv9I+k5SANTW5HHyShb3AAYjQSNfaZY3zCTTtnTNyxr3XbCirW0ffX7SClZ9gaKZhPGy/diEUPMpKAQFgpcQGVx7WLu3/HRP2pWDSAUF0wFse71ly8qOi2MaRxwPDhVnhsI8vqp/2P4KvYrsZXuR2WMzn2/dtJOiTknxO7BlB+ahxya1B8DjK+ZO/ewAOv0jfa7KOr4E0fF8iO/UAdvQa/KSmp5pRoffOkon78RFJMNxOXj7XLILam5OcRb3xZ49lLOynZi2WgoDVLPzvugYjemkFMwJBdtUmOpTZ6/LJx9WxwMaFj7OqCm/LI8DtuCpmS4vzBLLG124rNooiMlSIUFf5y6VGG2cCHTB4s8IvnNFIPYJiHb2pSUhbg+cXTlRqzYmM26m6sZuNEC8/15UagAE7mr6BUcv/WY1SLZ+qsMMPI2r9J2cTB29z1rXA1hOd+psMxFeibsAtQjV6VCNL4qbqNeDR/QEJcoPdDyRnw/XSXhXzMvieCpAvQZufL3qq2/Umhhphwyn9f3GVSJO5qYAmIGNsF1GbbVa2Dj+JAjlg+OXA6/5EiuVkQ+hajVbizCAA",
                expiration: "2025-05-29T13:57:15Z",
                region: "oss-cn-shanghai",
                bucket: "voicego-image"
            )
        },
        getToolConversationList: { studyToolUsedId,  page, pageSize in
            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)
            let resp =  StrapiResponse(
                data: ToolConversation.sample,
                meta: meta
            )
            return resp
        },
        createToolConversation: { studyTool, query in
            let response = StrapiResponse(
                data: ToolConversation.sample[0],
                meta: nil
            )
            return response
        },
        streamToolConversation: {studyTool, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
                    
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break;
                        case .complete(let completion):
                            if let httpResponse = completion.response, let request = completion.request{
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                                }
                                else{
                                    continuation.finish()
                                }
                            }
                        }
                    })
                }
            }
        }
    )
}

extension VoiceGoAPIClient : TestDependencyKey  {
    static var testValue = Self(
        fetchStudyTools: { _ in
            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)


            let resp =  StrapiResponse(
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
        getToolConversationList: {studyToolUsedId, page, pageSize in
            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)


            let resp =  StrapiResponse(
                data: ToolConversation.sample,
                meta: meta
            )
            return resp
        },
        createToolConversation: { studyTool, query in
            let response = StrapiResponse(
                data: ToolConversation.sample[0],
                meta: nil
            )
            return response
        },
        streamToolConversation: {studyTool, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
                    
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break;
                        case .complete(let completion):
                            if let httpResponse = completion.response, let request = completion.request{
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                                }
                                else{
                                    continuation.finish()
                                }
                            }
                        }
                    })
                }
            }
        }
    )
}

extension DependencyValues {
    var apiClient: VoiceGoAPIClient {
        get { self[VoiceGoAPIClient.self] }
        set { self[VoiceGoAPIClient.self] = newValue }
    }
}

// swiftlint:enable line_length
