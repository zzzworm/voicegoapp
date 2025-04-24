//
//  StudyToolListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture
import StrapiSwift

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
        case fetchStudyToolsResponse(TaskResult<StrapiResponse<[StudyTool]>>)
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
                    do{
                        let result = try await apiClient.fetchStudyTools()
                        await send(.fetchStudyToolsResponse(.success(result)))
                    }
                    catch{
                        await send(.fetchStudyToolsResponse(.failure(error)))
                    }
                    
                }
                
            case .fetchStudyToolsResponse(.success(let studyToolListRsp)):
                
                var studyToolList : [StudyTool] = []
                MainActor.assumeIsolated{
                    studyToolList = studyToolListRsp.data
                }
                state.dataLoadingStatus = .success
                state.studyToolListState = IdentifiedArrayOf(
                    uniqueElements: studyToolList.map {
                        StudyToolDomain.State(
                            studyToolUsedID: $0.documentId,
                            studyTool: $0,
                            card: $0.exampleCard,
                            toolHistoryListState: IdentifiedArrayOf(uniqueElements: []),
                            inputBarState: BottomInputBarDomain.State()
                        )
                    }
                )
                
                return .run { _ in
                    
                    try await self.database.write { db in
                        for studyTool in studyToolList {
                            
                            var studyToolMutable = studyTool
                                var qaCard = studyToolMutable.exampleCard
                                if var qaCard = qaCard {
                                    try qaCard.upsert(db)
                                }
                                let ret = try studyToolMutable.upsert(db)
                            
                        }
                    }
                    
                }
                
                
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
