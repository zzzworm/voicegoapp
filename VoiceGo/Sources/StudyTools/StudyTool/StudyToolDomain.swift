//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture

struct StudyToolDomain: Reducer {
    @Dependency(\.uuid) var uuid
    
    struct State: Equatable, Identifiable {
        let id: UUID
        let studyTool: StudyTool
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var card : QACard
        var toolHistoryListState: IdentifiedArrayOf<ToolHistoryDomain.State> = []
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        var inputBarState = BottomInputBarDomain.State()
    }
    
    enum Action: Equatable {
        case fetchStudyHistory
        case fetchStudyHistoryResponse(TaskResult<[ToolHistory]>)
        case toolHistory(id: ToolHistoryDomain.State.ID, action: ToolHistoryDomain.Action)
        case inputBar(BottomInputBarDomain.Action)
    }

    @Dependency(\.aiServiceClient) var aiServiceClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.inputBarState, action: /Action.inputBar) {
            BottomInputBarDomain()
        }
        Reduce { state, action in
            switch action {
            case .fetchStudyHistory:
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                state.dataLoadingStatus = .loading
                return .run{ send in
                    let query = ConversationQuery(user: "a5e5f0cc-6ee7-4aad-af69-56fa085ee3f6")
                    let result = await TaskResult {
                        let resp = try await aiServiceClient.getSessionList(query)
                        do {
                            let rsp = try JSONDecoder().decode(ConversationRsp.self, from: resp.data)
                            var result = [ToolHistory]()
                            rsp.data.map { item in
                                let history = ToolHistory.sample[0]
                                result.append(history)
                            }
                            return result
                        }
                        catch {
                            print("Error decoding JSON: \(error)")
                            return []
                        }
                       
                    }
                    return await send(.fetchStudyHistoryResponse(result))
                }
                
            case .fetchStudyHistoryResponse(.success(let toolHistoryList)):
                state.dataLoadingStatus = .success
                state.toolHistoryListState = IdentifiedArrayOf(uniqueElements: toolHistoryList.map { history in
                    let uuid = self.uuid() // Use the dependency for generating a unique ID
                    return ToolHistoryDomain.State(id: uuid, history: history)
                })
                return .none
            case .fetchStudyHistoryResponse(.failure(_)):
                state.dataLoadingStatus = .error
                return .none
            case .toolHistory(id: let id, action: let action):
                return .none
            case .inputBar(let action):
                switch action {
                case .binding(_):
                    break
                case .inputTextChanged(_):
                    break
                case .speechRecognitionInput(_):
                    break
                case .submitText(let query):
                    return .run{send in
                        let rsp = try await aiServiceClient.sendChatMessage(query,.streaming,{ eventSource in
                            switch eventSource.event {
                            case .message(let message):
                                print("Received message: \(message)")
                            case .complete(let completion):
                                print("Stream completed with: \(completion)")
                            }
                        })
                    }
                case .toggleSpeechMode:
                    break
                }
                return .none
            }
        }
        .forEach(\.toolHistoryListState, action: /Action.toolHistory) {
            ToolHistoryDomain()
        }
        
    }
}
