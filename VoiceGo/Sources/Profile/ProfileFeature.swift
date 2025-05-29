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
        case fetchUserProfileFromDB
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
                    return .none
                    
                case let .updateProfileResponse(.failure(error)):
                    state.isLoading = false
                    state.alert = AlertState(title: TextState("更新失败"),
                                          message: TextState(error.localizedDescription))
                    return .none
                }
                
            case let .path(.element(id: _, action: .edit(.delegate(.didUpdateProfile(profile))))):
                state.profile = profile
                state.path.removeAll()
                return .none
                
            case .path:
                return .none
                
            case .alert:
                return .none
                
            case .fetchUserProfileFromDB:
                return .run { send in
                    if let profile = try await database.read({ db in
                        try UserProfile.fetchOne(db)
                    }) {
                        await send(.internal(.updateProfileResponse(.success(profile))))
                    }
                }
                
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
    }
}
