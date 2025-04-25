//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture
import StrapiSwift
import SwiftyJSON

struct StudyToolDomain: Reducer {
    @Dependency(\.uuid) var uuid
    
    struct State: Equatable, Identifiable {
        let studyTool: StudyTool
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var card : QACard?
        var toolHistoryListState: IdentifiedArrayOf<ToolHistoryDomain.State> = []
        var currenttoolHistory: ToolHistoryDomain.State?
//        var lastIndex = 0;
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        var inputBarState = BottomInputBarDomain.State()
        var paginationState : Pagination?
        var isLoadMore = false
        var id : String {
            studyTool.documentId
        }
    }
    
    enum Action: Equatable {
        case fetchStudyHistory(page: Int = 1, pageSize: Int = 10)
        case fetchStudyHistoryResponse(TaskResult<StrapiResponse<[ToolConversation]>>)
        case toolHistory(id: ToolHistoryDomain.State.ID, action: ToolHistoryDomain.Action)
        case inputBar(BottomInputBarDomain.Action)
        case streamAnswer(String)
        case complete(ToolConversation)
        case viewIndex(Int)
    }

    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.inputBarState, action: /Action.inputBar) {
            BottomInputBarDomain()
        }
        Reduce { state, action in
            switch action {
            case .fetchStudyHistory(let page, let pageSize):
                if state.dataLoadingStatus == .loading {
                    return .none
                }
                state.dataLoadingStatus = .loading
                let studyToolUsedID = state.studyTool.documentId
                return .run{ send in
                    do{
                        let result =  try await apiClient.getToolConversationList(studyToolUsedID, page, pageSize)
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
                    state.isLoadMore = false
                    state.dataLoadingStatus = .success
                    if let page = state.paginationState?.page, page == 1{
                        state.toolHistoryListState = IdentifiedArrayOf(uniqueElements: toolHistoryList.reversed().map { history in
                            return ToolHistoryDomain.State( history: history)
                        })
                    }
                    else{
                        
                        let addIdentifiedArray = IdentifiedArrayOf(uniqueElements: toolHistoryList.reversed().map { history in
                            return ToolHistoryDomain.State( history: history)
                        })
                        //新到的下一页内容往前插入
                        state.toolHistoryListState.insert(contentsOf: addIdentifiedArray, at: 0)
                    }
                }
                return .none
            case .fetchStudyHistoryResponse(.failure(_)):
                state.dataLoadingStatus = .error
                state.isLoadMore = false
                return .none
            case .streamAnswer(let answer):
                if var currentToolHistory = state.currenttoolHistory {
                        currentToolHistory.history.answer += answer
                }
                return .none
            case .complete(let history):
                guard var currentToolHistory = state.currenttoolHistory else { return .none }
                currentToolHistory.history = history
//                state.toolHistoryListState.update(currentToolHistory, at: state.lastIndex)
                state.currenttoolHistory = nil
//                state.lastIndex = 0
                return .none
            case let .viewIndex(index):
                guard index == 3, !state.isLoadMore, let total = state.paginationState?.total, state.toolHistoryListState.count < total, !state.isLoadMore else { return .none }
                if let page = state.paginationState!.page, let pageSize = state.paginationState!.pageSize {
                    state.isLoadMore = true
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
                    let toolHistoryState = ToolHistoryDomain.State(history: ToolConversation(documentId:"",id:0,updatedAt: .now, query: query, answer: "", message_id: "", conversation_id: ""))
                    state.currenttoolHistory = toolHistoryState
                    let (inserted, index) = state.toolHistoryListState.append(toolHistoryState)
//                    state.lastIndex = index
                    return .run{ send in
                        let request = try await apiClient.streamToolConversation(studyTool,query,{ eventSource in
                            switch eventSource.event {
                            case .message(let message):
                                guard let event = message.event, let dataString = message.data ,let jsonData = dataString.data(using:.utf8) else {
                                    print("No event")
                                    return
                                }
                                    if (event == "message") {
                                        do {
                                            // 使用 SwiftyJSON 解析 JSON 数据
                                            let json = try JSON(data: jsonData)
                                            if let answer = json["answer"].string{
                                                Task{
                                                    await send(.streamAnswer(answer))
                                                }
                                            }
                                            
                                        } catch {
                                            print("解析 JSON 数据时出错: \(error)")
                                        }
                                        
                                        return
                                    }
                                    else if(event == "complete"){
                                        do {
                                            // 使用 SwiftyJSON 解析 JSON 数据
                                            let toolHistory = try JSONDecoder.default.decode(ToolConversation.self, from: jsonData)
                                            Task{
                                                await send(.complete(toolHistory))
                                            }
                                            
                                        } catch {
                                            print("解析 JSON 数据时出错: \(error)")
                                        }
                                    }
                                
                                
                            case .complete(let completion):
                                print("Stream completed with: \(completion)")
                                if let httpResponse = completion.response, let request = completion.request{
                                    
                                        
                                    
                                }
    
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
