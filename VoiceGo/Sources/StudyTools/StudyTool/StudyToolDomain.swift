//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture
import StrapiSwift

struct StudyToolDomain: Reducer {
    @Dependency(\.uuid) var uuid
    
    struct State: Equatable, Identifiable {
        let studyToolUsedID: String
        let studyTool: StudyTool
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var card : QACard?
        var toolHistoryListState: IdentifiedArrayOf<ToolHistoryDomain.State> = []
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        var inputBarState = BottomInputBarDomain.State()
        var paginationState : Pagination?
        var isLoadMore = false
        var id : String {
            studyToolUsedID
        }
    }
    
    enum Action: Equatable {
        case fetchStudyHistory(page: Int = 1, pageSize: Int = 10)
        case fetchStudyHistoryResponse(TaskResult<StrapiResponse<[ToolConversation]>>)
        case toolHistory(id: ToolHistoryDomain.State.ID, action: ToolHistoryDomain.Action)
        case inputBar(BottomInputBarDomain.Action)
        case loadMore(Int)
    }

    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.inputBarState, action: /Action.inputBar) {
            BottomInputBarDomain()
        }
        Reduce { state, action in
            switch action {
            case .fetchStudyHistory(let page, let pageSize):
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                state.dataLoadingStatus = .loading
                let studyToolUsedID = state.studyToolUsedID
                return .run{ send in
                    do{
                    let result =  try await apiClient.getToolConversationList(studyToolUsedID,0, 10)
                        return await send(.fetchStudyHistoryResponse(.success(result)))
                        }
                        catch {
                            return await send(.fetchStudyHistoryResponse(.failure(error)))
                        }
                       
                    }
            
                
            case .fetchStudyHistoryResponse(.success(let toolHistoryListRsp)):
                MainActor.assumeIsolated{
                    let toolHistoryList = toolHistoryListRsp.data
                    state.paginationState = toolHistoryListRsp.meta?.pagination
                    
                    state.dataLoadingStatus = .success
                    if let page = state.paginationState?.page, page == 1{
                        state.toolHistoryListState = IdentifiedArrayOf(uniqueElements: toolHistoryList.map { history in
                            let uuid = self.uuid() // Use the dependency for generating a unique ID
                            return ToolHistoryDomain.State(id: uuid, history: history)
                        })
                    }
                    else{
                        
                        let addIdentifiedArray = IdentifiedArrayOf(uniqueElements: toolHistoryList.map { history in
                            let uuid = self.uuid() // Use the dependency for generating a unique ID
                            return ToolHistoryDomain.State(id: uuid, history: history)
                        })
                        state.toolHistoryListState.append(contentsOf: addIdentifiedArray)
                    }
                }
                return .none
            case .fetchStudyHistoryResponse(.failure(_)):
                state.dataLoadingStatus = .error
                return .none
            case let .loadMore(index):
                    guard  state.toolHistoryListState.count > 4,
                          index == state.toolHistoryListState.count - 4, !state.isLoadMore else { return .none }
                if let page = state.paginationState!.page, let pageSize = state.paginationState!.pageSize {
                    return .run{ send in
                        await send(.fetchStudyHistory(page: page+1, pageSize: pageSize))
                    }
                }
                else{
                    return .none
                }
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
                    if query.isEmpty {
                        return .none
                    }
                    let studyTool = state.studyTool
            
                    return .run{ send in
                        let rsp = try await apiClient.streamToolConversation(studyTool,query,{ eventSource in
                            switch eventSource.event {
                            case .message(let message):
                                print("Received message: \(message)")
                            case .complete(let completion):
                                print("Stream completed with: \(completion)")
                                let history = ToolConversation.sample[0]
                                let uuid = self.uuid()
                                let toolHistory = ToolHistoryDomain.State(id: uuid, history: history)
//                                state.toolHistoryListState.append(toolHistory)
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
