//
//  EmailLoginFeature.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 12.04.23.
//

import SwiftUI
import ComposableArchitecture
import SharingGRDB

@Reducer
struct EmailLoginFeature {
    
    @ObservableState
    struct State: Equatable {
        var isActivityIndicatorVisible = false
        var userIdentifier = "StrapiUser1"
        var password = "password123"
        
        @Presents var alert: AlertState<Never>?
    }
    
    enum Action: Equatable, BindableAction {
        enum ViewAction: Equatable {
            case onSignInButtonTap
            case onSignUpButtonTap
            case onForgotPasswordButtonTap
        }
        
        enum InternalAction: Equatable {
            case loginResponse(TaskResult<AuthenticationResponse>)
        }
        
        enum Delegate {
            case didEmailAuthenticated
            case didForgotPasswordPressed
            case didRegisterPressed
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
        case binding(BindingAction<State>)
        case alert(PresentationAction<Never>)
    }
    
    private enum CancelID { case login }
    
    @Dependency(\.authenticationClient) var authenticationClient
    @Dependency(\.userKeychainClient) var userKeychainClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.userDefaults) var userDefaultsClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            // view actions
            case let .view(viewAction):
                switch viewAction {
                case .onSignInButtonTap:
                    state.isActivityIndicatorVisible = true
                    return .run { [userIdentifier = state.userIdentifier, password = state.password] send in
                        await send(
                            .internal(
                                .loginResponse(
                                    await TaskResult {
                                        try await self.authenticationClient.login(
                                            .init(identifier: userIdentifier, password: password)
                                        )
                                    }
                                )
                            )
                        )
                    }
                    .cancellable(id: CancelID.login)
                    
                case .onForgotPasswordButtonTap:
                    return .send(.delegate(.didForgotPasswordPressed))
                case .onSignUpButtonTap:
                    return .send(.delegate(.didRegisterPressed))
                }
                
            // internal actions
            case let .internal(internalAction):
                switch internalAction {
                case let .loginResponse(.success(data)):
                    state.isActivityIndicatorVisible = false
                    
                    return .concatenate(
                        .run { _ in
                            await handleLoginResponse(data: data)
                        },
                        .send(.delegate(.didEmailAuthenticated))
                    )
                    
                case let .loginResponse(.failure(error)):
                    Log.error("loginResponse: \(error)")
                    state.isActivityIndicatorVisible = false
                    state.alert = AlertState { TextState(error.localizedDescription) }
                    return .none
                }
                            
            case .delegate, .alert:
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
