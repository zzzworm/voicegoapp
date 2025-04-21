//
//  ProfileDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import ComposableArchitecture
import SharingGRDB

struct ProfileDomain: Reducer {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.userDefaults) var userDefaultsClient
    
    struct State: Equatable {
        var profile: UserProfile? = .default
        fileprivate var dataState = DataState.notStarted
        var isLoading: Bool {
            dataState == .loading
        }
    }
    
    fileprivate enum DataState {
        case notStarted
        case loading
        case complete
    }
    
    enum Action: Equatable {
        case fetchUserProfileFromDB
        case fetchUserProfileFromServer
        case fetchUserProfileResponse(TaskResult<UserProfile>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
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
        }
    }
}
