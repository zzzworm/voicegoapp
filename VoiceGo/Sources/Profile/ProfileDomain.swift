//
//  ProfileDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import ComposableArchitecture
import SharingGRDB
import SwiftUI

@Reducer
struct ProfileDomain {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.userDefaults) var userDefaultsClient
    
    @ObservableState
    struct State : Equatable {
        var profile: UserProfile? = nil
        fileprivate var dataState = DataState.notStarted
        var isLoading: Bool {
            dataState == .loading
        }
        var path = StackState<Path.State>()
    }
    
    
    
    @Reducer(state: .equatable)
    enum Path {
        case setting(ProfileSettingDomain)
        }
    
    fileprivate enum DataState {
        case notStarted
        case loading
        case complete
    }
    
    
    enum Action: BindableAction {
        
        enum ViewAction: Equatable {
                    case onSettingTapped
                }
        
        enum Delegate: Equatable {
            case didLogout
        }
        case fetchUserProfileFromDB
        case fetchUserProfileFromServer
        case fetchUserProfileResponse(TaskResult<UserProfile>)
        case view(ViewAction)
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }

    
    var body: some ReducerOf<Self> {
        BindingReducer()
            Reduce { state, action in
                switch action {
                case let .view(viewAction):
                    switch viewAction {
                    case .onSettingTapped:
                        state.path.append(.setting(.init()))
                    }
                    return .none
                case .fetchUserProfileFromDB:
                    return .run { send in
                        let userID = try await self.userDefaultsClient.currentUserID
                        let result = await TaskResult { try await database.read { db in
                            
                            if let user = try UserProfile.fetchOne(db, key: [ UserProfile.ProfileKeys.documentId.stringValue : userID]) {
                                return user
                            }
                            else{
                                throw NSError(domain: "UserProfile", code: 0, userInfo: nil)
                            }
                        } }
                        
                        await send(.fetchUserProfileResponse(result))
                    }
                case .fetchUserProfileFromServer:
                    if  state.dataState == .loading {
                        return .none
                    }
                    state.dataState = .loading
                    return .run { send in
                        let result = await TaskResult { try await apiClient.fetchUserProfile() }
                        await send(.fetchUserProfileResponse(result))
                    }
                    
                case .fetchUserProfileResponse(.success(let profile)):
                    state.dataState = .complete
                    state.profile = profile
                    return .none
                case .fetchUserProfileResponse(.failure(let error)):
                    state.dataState = .complete
                    print("Error: \(error)")
                    return .none
                case let .path(pathAction):
                                switch pathAction {
                                case .element(id: _, action: .setting(.logout)):
                                    return .run { send in
                                        await send(.delegate(.didLogout))
                                    }
                                default:
                                    return .none
                                }
                case .binding,.delegate:
                    return .none
                }
            }
            .forEach(\.path, action: \.path)
        
    }
}
