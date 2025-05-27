//
//  StudyToolListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture
import StrapiSwift

@Reducer
struct StudyToolsFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.apiClient) var apiClient
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var currentTag : StudyTool.ToolTag = .language_study
        var studyToolList: IdentifiedArrayOf<StudyTool> = []

        var cachedToolList: [ StudyTool.ToolTag :IdentifiedArrayOf<StudyTool>] = [:]

        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
    }
    
    enum Action {
        enum ViewAction: Equatable {
            case onToolHistoryTap(StudyTool)
        }
        case view(ViewAction)
        case switchTools(StudyTool.ToolTag)
        case fetchStudyToolUsedList(StudyTool.ToolTag)
        case fetchStudyToolsResponse(TaskResult<StrapiResponse<[StudyTool]>>)
        case path(StackActionOf<Path>)
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case studyTool(StudyToolFeature)
    }
    
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchStudyToolUsedList(let categoryTag):
                if state.dataLoadingStatus == .loading {
                    return .none
                }
                
                state.dataLoadingStatus = .loading
                return .run { send in
                    do{
                        let result = try await apiClient.fetchStudyTools(categoryTag.rawValue)
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
                state.studyToolList = IdentifiedArrayOf(uniqueElements: studyToolList)
                state.cachedToolList[state.currentTag] = state.studyToolList
                
                
                Task{
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
                return .none
                
                
            case .fetchStudyToolsResponse(.failure(let error)):
                state.dataLoadingStatus = .error
                print(error)
                print("Error getting StudyTools, try again later.")
                return .none
                

            case .switchTools(let category):
                state.currentTag = category
                if let tools = state.cachedToolList[category]{
                    state.studyToolList = tools
                    return .none
                }
                else{
                    return .send(.fetchStudyToolUsedList(category))
                }
                
        
            case let .path(pathAction):
                return .none
            case .view(let viewAction):
                switch viewAction {
                case .onToolHistoryTap(let studyTool):
                    state.path.append(.studyTool(.init(studyTool: studyTool)))
                    return .none
                }
            }
        }.forEach(\.path, action: \.path)
    }
    
}
