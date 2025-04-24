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
    @Dependency(\.apiClient) var apiClient
    
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
        case fetchStudyToolUsedList
        case fetchStudyToolUsedListResponse(TaskResult<[StudyToolUsed]>)
        case studyTool(id: StudyToolDomain.State.ID, action: StudyToolDomain.Action)
    }
    
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchStudyToolUsedList:
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                
                state.dataLoadingStatus = .loading
                return .run { send in
                    let result = await TaskResult {
                        let ret = try await apiClient.fetchStudyTools()
                        return await ret.data
                    }
                    await send(.fetchStudyToolUsedListResponse(result))
                }
                
            case .fetchStudyToolUsedListResponse(.success(let studyToolUsedList)):
                state.dataLoadingStatus = .success
                state.studyToolListState = IdentifiedArrayOf(
                    uniqueElements: studyToolUsedList.map {
                        StudyToolDomain.State(
                            studyToolUsedID: $0.documentId,
                            studyTool: $0.studyTool!
                        )
                    }
                )
                return .run { _ in
                    
                    try await self.database.write { db in
                        for studyToolUsed in studyToolUsedList {
                            
                            if var studyToolMutable = studyToolUsed.studyTool {
                                var qaCard = studyToolMutable.exampleCard
                                if var qaCard = qaCard {
                                    try qaCard.upsert(db)
                                }
                                let ret = try studyToolMutable.upsert(db)
                            }
                            var studyToolUsedMutable = studyToolUsed
                            try studyToolUsedMutable.upsert(db)
                        }
                    }
                    
                }
                
            case .fetchStudyToolUsedListResponse(.failure(let error)):
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
