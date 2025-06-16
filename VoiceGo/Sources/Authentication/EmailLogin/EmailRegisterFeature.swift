//
//  EmailRegisterFeature.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 12.04.23.
//

import SwiftUI
import ComposableArchitecture
import SharingGRDB

@Reducer
struct EmailRegisterFeature {

    @ObservableState
    struct State: Equatable {
        var isActivityIndicatorVisible = false
        var username = "StrapiUser1"
        var email = "StrapiUser1@example.com"
        var password = "password123"
        var retypePassword = "password123"

        @Presents var alert: AlertState<Never>?
    }

    enum Action: Equatable, BindableAction {
        enum ViewAction: Equatable {
            case onConfirmButtonTap
        }

        enum InternalAction: Equatable {
            case loginResponse(TaskResult<AuthenticationResponse>)
        }

        enum Delegate {
            case didEmailAuthenticated
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
                case .onConfirmButtonTap:
                    if state.password != state.retypePassword {
                        state.alert = AlertState { TextState("两次输入的密码不一致") }
                        return .none
                    }
                    state.isActivityIndicatorVisible = true
                    return .run { [username = state.username, email = state.email, password = state.password] send in
                        await send(
                            .internal(
                                .loginResponse(
                                    await TaskResult {
                                        let registerRequest = RegisterEmailRequest(
                                            email: email,
                                            username: username,
                                            password: password
                                        )
                                        return try await self.authenticationClient.register(registerRequest)
                                    }
                                )
                            )
                        )
                    }
                    .cancellable(id: CancelID.login)

                }

            // internal actions
            case let .internal(internalAction):
                switch internalAction {
                case let .loginResponse(.success(data)):
                    Log.info("loginResponse: \(data)")
                    state.isActivityIndicatorVisible = false
                    userKeychainClient.storeToken(data.jwt)

                    return .concatenate(
                        .run { _ in
                            var account = data.user
                            try await self.database.write { db in
                                try account.insert(db)
                            }
                            try await self.userDefaultsClient.setCurrentUserID(account.documentId)
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
