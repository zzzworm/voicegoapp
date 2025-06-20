//
//  ProductFeature.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture
import StrapiSwift
import SwiftyJSON

@Reducer
struct StudyToolFeature {
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable, Identifiable {
        let studyTool: StudyTool
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var toolHistoryListState: IdentifiedArrayOf<ToolHistoryFeature.State> = []
        var currenttoolHistory: ToolHistoryFeature.State?
        var lastIndex = 0
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        var inputBarState = BottomInputBarFeature.State()
        var paginationState: Pagination?
        var isLoadMore = false
        var isScrolling = false
        var id: String {
            studyTool.documentId
        }
    }

    enum Action: Equatable, BindableAction {
        case fetchStudyHistory(page: Int = 1, pageSize: Int = 10)
        case fetchStudyHistoryResponse(TaskResult<StrapiResponse<[ToolConversation]>>)
        case toolHistory(IdentifiedActionOf<ToolHistoryFeature>)
        case inputBar(BottomInputBarFeature.Action)
        case streamAnswer(String)
        case complete(ToolConversation)
        case binding(BindingAction<State>)
        case viewIndex(Int)
    }

    private enum CancelID { case query }

    @Dependency(\.apiClient) var apiClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.inputBarState, action: /Action.inputBar) {
            BottomInputBarFeature()
        }
        Reduce { state, action in
            switch action {
            case .fetchStudyHistory(let page, let pageSize):
                if state.dataLoadingStatus == .loading {
                    return .none
                }
                if !state.isLoadMore {
                    state.dataLoadingStatus = .loading
                }
                let studyToolUsedID = state.studyTool.documentId
                return .run { send in
                    do {
                        let result =  try await apiClient.getToolConversationList(studyToolUsedID, page, pageSize)
                        return await send(.fetchStudyHistoryResponse(.success(result)))
                    } catch {
                        return await send(.fetchStudyHistoryResponse(.failure(error)))
                    }

                }

            case .fetchStudyHistoryResponse(.success(let toolHistoryListRsp)):
                MainActor.assumeIsolated {
                    let toolHistoryList = toolHistoryListRsp.data
                    state.paginationState = toolHistoryListRsp.meta?.pagination
                    state.isLoadMore = false
                    state.dataLoadingStatus = .success
                    if let page = state.paginationState?.page, page == 1 {
                        state.toolHistoryListState = IdentifiedArrayOf(uniqueElements: toolHistoryList.reversed().map { history in
                            return ToolHistoryFeature.State( history: history)
                        })
                    } else {

                        let addIdentifiedArray = IdentifiedArrayOf(uniqueElements: toolHistoryList.reversed().map { history in
                            return ToolHistoryFeature.State( history: history)
                        })
                        // 新到的下一页内容往前插入
                        state.toolHistoryListState.insert(contentsOf: addIdentifiedArray, at: 0)
                    }
                }
                return .none
            case .fetchStudyHistoryResponse(.failure):
                state.dataLoadingStatus = .error
                state.isLoadMore = false
                return .none
            case .streamAnswer(let result):
                if var currentToolHistory = state.currenttoolHistory {
                    if var answer = currentToolHistory.history.answer {
                        ToolConversationAnswer(answer: answer.answer + result)
                        currentToolHistory.history.answer = answer
                    } else {
                        currentToolHistory.history.answer = ToolConversationAnswer(answer: result)
                    }
                    state.currenttoolHistory = currentToolHistory
                    state.toolHistoryListState.update(currentToolHistory, at: state.lastIndex)
                }
                return .none
            case .complete(let history):
                guard var currentToolHistory = state.currenttoolHistory else { return .none }
                let toolHistoryState = ToolHistoryFeature.State(history: history)
                state.toolHistoryListState.remove(at: state.lastIndex)
                state.toolHistoryListState.insert(toolHistoryState, at: state.lastIndex)
                state.currenttoolHistory = nil
                state.lastIndex = 0
                return .none
            case let .viewIndex(index):
                guard index == 1, state.isScrolling, !state.isLoadMore, let total = state.paginationState?.total, state.toolHistoryListState.count < total, !state.isLoadMore else { return .none }
                if let page = state.paginationState!.page, let pageSize = state.paginationState!.pageSize {
                    state.isLoadMore = true
                    return .run { send in
                        await send(.fetchStudyHistory(page: page+1, pageSize: pageSize))
                    }
                } else {
                    return .none
                }
            case .toolHistory(let action):
                return .none
            case .inputBar(let action):
                switch action {
                case .binding:
                    break
                case .textChanged:
                    break
                case .speechRecognitionInput:
                    break
                case .submitText(let query):
                    if query.isEmpty || state.currenttoolHistory != nil {
                        return .none
                    }
                    let studyTool = state.studyTool
                    let toolHistoryState = ToolHistoryFeature.State(history: ToolConversation(documentId: self.uuid().uuidString,
                                                                                             id: 0,
                                                                                             updatedAt: .now,
                                                                                             query: query,
                                                                                              answer: .init(answer: ""),
                                                                                             message_id: "",
                                                                                             conversation_id: ""))
                    state.currenttoolHistory = toolHistoryState
                    var assist_content = "";
                    if let lastItem = state.toolHistoryListState.last {
                        assist_content = lastItem.history.answer?.answer ?? ""
                    }
                    let (inserted, index) = state.toolHistoryListState.append(toolHistoryState)
                    state.lastIndex = index

                    return .run { send in
                            for try await event in try await apiClient.streamToolConversation(studyTool, query, assist_content) {

                                switch event {
                                case .message(let message):
                                    guard let event = message.event, let dataString = message.data, let jsonData = dataString.data(using: .utf8) else {
                                        print("No event")
                                        return
                                    }
                                    do {
                                        if event == "message" {

                                            // 使用 SwiftyJSON 解析 JSON 数据
                                            let json = try JSON(data: jsonData)
                                            if let answer = json["answer"].string {
                                                await send(.streamAnswer(answer))
                                            }
                                        } else if event == "completed" {

                                            // 使用 SwiftyJSON 解析 JSON 数据
                                            let toolHistory = try JSONDecoder.default.decode(ToolConversation.self, from: jsonData)
                                            await send(.complete(toolHistory))
                                        }

                                    } catch {
                                        print("解析 JSON 数据时出错: \(error)")
                                    }
                                case .complete(let completion):
                                    print("Stream completed with: \(completion)")
                                }

                        }
                    }

                case .toggleSpeechMode:
                    break
                }
                return .none
            case .binding:
                return .none
            }
        }
        .forEach(\.toolHistoryListState, action: \.toolHistory) {
            ToolHistoryFeature()
        }

    }
}
