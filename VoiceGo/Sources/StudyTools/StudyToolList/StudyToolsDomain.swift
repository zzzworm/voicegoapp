//
//  StudyToolListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct StudyToolListDomain: Reducer {
    @Dependency(\.uuid) var uuid
    //@Dependency(\.apiClient) var apiClient

    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var shouldOpenCart = false
        var studyToolListState: IdentifiedArrayOf<StudyToolDomain.State> = []
        
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case fetchStudyTools
        case fetchStudyToolsResponse(TaskResult<[StudyTool]>)
        case studyTool(id: StudyToolDomain.State.ID, action: StudyToolDomain.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchStudyTools:
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }

                state.dataLoadingStatus = .loading
                return .run { send in
//                    let result = await TaskResult { try await apiClient.fetchStudyTools() }
//                   await send(.fetchStudyToolsResponse(result))
//                   await .fetchStudyToolsResponse(
//                       TaskResult { result }
//                   )
                }
            case .fetchStudyToolsResponse(.success(let studyTools)):
                state.dataLoadingStatus = .success
                state.studyToolListState = IdentifiedArrayOf(
                    uniqueElements: studyTools.map {
                        StudyToolDomain.State(
                            id: uuid(),
                            studyTool: $0
                        )
                    }
                )
                return .none
            case .fetchStudyToolsResponse(.failure(let error)):
                state.dataLoadingStatus = .error
                print(error)
                print("Error getting StudyTools, try again later.")
                return .none
            

            case .studyTool:
                return .none
            }
        }
        .forEach(\.studyToolListState, action: /Action.studyTool) {
            StudyToolDomain()
        }
    }


}
