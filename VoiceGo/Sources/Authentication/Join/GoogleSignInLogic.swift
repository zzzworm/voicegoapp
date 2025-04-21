//
//  GoogleSignInLogic.swift
//  Shop
//
//  Created by Anatoli Petrosyants on 07.10.24.
//

import Foundation
import UIKit
import ComposableArchitecture
import SharingGRDB

struct GoogleSignInLogic<State>: Reducer {

    @Dependency(\.googleSignInClient) var googleSignInClient
    @Dependency(\.userKeychainClient) var userKeychainClient
    @Dependency(\.userDefaults) var userDefaultsClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.mainQueue) var mainQueue
    
    func reduce(into _: inout State, action: JoinFeature.Action) -> Effect<JoinFeature.Action> {
        switch action {
        case let .loginOptions(.presented(.delegate(loginOptionsAction))):
            switch loginOptionsAction {
            case .didGoogleLoginButtonSelected:
                guard let root = UIApplication.shared.firstKeyWindow?.rootViewController else {
                    return .none
                }

                return .run { send in
                    await send(
                        .internal(
                            .loginResponse(
                                await TaskResult {
                                    try await self.googleSignInClient.login(
                                        root
                                    )
                                }
                            )
                        )
                    )
                }

            default:
                return .none
            }
            
        case let .internal(internalAction):
            switch internalAction {
            case let .loginResponse(.success(data)):                
                userKeychainClient.storeToken(data.jwt)
                return .run { send in
                    try await userDefaultsClient.setToken(data.jwt)
                    var account = data.user
                    try await self.database.write { db in
                        try account.insert(db)
                    }
                    try await self.userDefaultsClient.setCurrentUserID(account.documentId)
                    await send(.delegate(.didAuthenticated))
                }
                
            case let .loginResponse(.failure(error)):
                Log.error("loginResponse: \(error)")
                return .none
                
            default:
                return .none
            }
        

        default:
            return .none
        }
    }
}
