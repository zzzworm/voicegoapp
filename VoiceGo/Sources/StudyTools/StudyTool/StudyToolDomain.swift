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
        var inputText: String = ""
        var isKeyboardVisible: Bool = false
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
    }
    
    enum Action: Equatable {
        case fetchStudyHistory
        case fetchStudyHistoryResponse(TaskResult<[ToolHistory]>)
        case toolHistory(id: ToolHistoryDomain.State.ID, action: ToolHistoryDomain.Action)
        case inputTextChanged(String)
        case keyboardWillShow
        case keyboardWillHide
    }

    var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
            case .fetchStudyHistory:
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                state.toolHistoryListState = IdentifiedArrayOf(uniqueElements: ToolHistory.sample.map { history in
                    let uuid = self.uuid() // Use the dependency for generating a unique ID
                    return ToolHistoryDomain.State(id: uuid, history: history)
                })
                    return .none
                
            case .fetchStudyHistoryResponse(.success(let toolHistoryList)):
                state.dataLoadingStatus = .success
                state.toolHistoryListState = IdentifiedArrayOf(uniqueElements: toolHistoryList.map { history in
                    let uuid = self.uuid() // Use the dependency for generating a unique ID
                    return ToolHistoryDomain.State(id: uuid, history: history)
                })
                return .none
            case .fetchStudyHistoryResponse(.failure(_)):
                return .none
            case .toolHistory(id: let id, action: let action):
                return .none
            case .inputTextChanged(let text):
                state.inputText = text
                return .none
            case .keyboardWillShow:
                state.isKeyboardVisible = true
                return .none
            case .keyboardWillHide:
                state.isKeyboardVisible = false
                return .none
            }
        }
        .forEach(\.toolHistoryListState, action: /Action.toolHistory) {
            ToolHistoryDomain()
        }
        
    }
}
