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
        var shouldOpenCart = false
        var studyToolList: IdentifiedArrayOf<StudyTool> = []
        var availableToolList: IdentifiedArrayOf<StudyTool> = [] // 可用工具列表
        var isShowingUsedTools = true // 当前是否展示已使用工具

        var currentToolList: IdentifiedArrayOf<StudyTool> {
            isShowingUsedTools ? studyToolList : availableToolList
        }

        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
    }
    
    enum Action {
        enum ViewAction: Equatable {
            case onToolHistoryTap(StudyTool)
        }
        case view(ViewAction)
        case fetchCurrentToolList
        case switchToUsedTools
        case switchToAvailableTools
        case fetchStudyToolUsedList
        case fetchAvailableToolList
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
                state.studyToolList = IdentifiedArrayOf(uniqueElements: studyToolList)
                
                
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
                
            case .switchToUsedTools:
                state.isShowingUsedTools = true
                return .send(.fetchCurrentToolList)

            case .switchToAvailableTools:
                state.isShowingUsedTools = false
                return .send(.fetchCurrentToolList)

            case .fetchCurrentToolList:
                return state.isShowingUsedTools
                    ? .send(.fetchStudyToolUsedList)
                    : .send(.fetchAvailableToolList)
        
            case let .path(pathAction):
                return .none
            case .view(let viewAction):
                switch viewAction {
                case .onToolHistoryTap(let studyTool):
                    state.path.append(.studyTool(.init(studyTool: studyTool)))
                    return .none
                }
            case .fetchAvailableToolList:
                return .none
            }
        }.forEach(\.path, action: \.path)
    }
    
}
