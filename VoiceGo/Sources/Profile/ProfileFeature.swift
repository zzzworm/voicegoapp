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
struct ProfileFeature {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.userDefaults) var userDefaultsClient
    
    @ObservableState
    struct State : Equatable {
        var isLoading = false
        var profile: UserProfile?
        var path = StackState<Path.State>()
        
        @Presents var alert: AlertState<Never>?
    }
    
    enum Action: BindableAction {
        enum ViewAction: Equatable {
            case onSettingTapped
            case onEditProfileTapped
        }
        
        enum InternalAction: Equatable {
            case updateProfileResponse(TaskResult<UserProfile>)
        }
        
        case `internal`(InternalAction)
        case alert(PresentationAction<Never>)
        case fetchUserProfileFromServer
        
        case view(ViewAction)
        case path(StackActionOf<Path>)
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case setting(ProfileSettingFeature)
        case edit(ProfileEditFeature)
    }
    
    fileprivate enum DataState {
        case notStarted
        case loading
        case complete
    }
    
    enum Delegate: Equatable {
        case didLogout
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onSettingTapped:
                    state.path.append(.setting(ProfileSettingFeature.State()))
                    return .none
                    
                case .onEditProfileTapped:
                    if let profile = state.profile {
                        state.path.append(.edit(ProfileEditFeature.State(profile: profile)))
                    }
                    return .none
                }
                
            case let .internal(internalAction):
                switch internalAction {
                case let .updateProfileResponse(.success(profile)):
                    state.profile = profile
                    state.isLoading = false
                    Task{
                        do {
                            try await database.write { db in
                                var profile = profile
                                if var studySetting = profile.study_setting {
                                    try studySetting.upsert(db)
                                    profile.studySettingId = studySetting.id
                                }
                                try profile.upsert(db)
                            }
                        } catch {
                            Log.error("Failed to save user to database: \(error)")
                        }
                    }
                    return .none
                    
                case let .updateProfileResponse(.failure(error)):
                    state.isLoading = false
                    state.alert = AlertState(title: TextState("更新失败"),
                                             message: TextState(error.localizedDescription))
                    return .none
                }
                
            case .path(.element(id: _, action: .edit(.delegate(.didUpdateProfile(let profile))))):
                state.profile = profile
                state.path.removeAll()
                return .none
            case .path(.element(id: _, action: .setting(.delegate(.didLogout)))):
                // Handle logout
                state.path.removeAll()
                return .send(.delegate(.didLogout))
            case .path(.element(id: _, action: .setting(let settingAction))):
                return .none
            case .path:
                return .none
                
            case .alert:
                return .none
                
            case .fetchUserProfileFromServer:
                state.isLoading = true
                return .run { send in
                    await send(.internal(.updateProfileResponse(
                        TaskResult { try await apiClient.fetchUserProfile() }
                    )))
                }
            case .binding(_):
                return .none
            case .delegate(_):
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$alert, action: /Action.alert)
    }
}
