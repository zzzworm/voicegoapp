//
//  ForgotPasswordFeature.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ForgotPasswordFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.AlertAction>?
        var userIdentifier = ""
    }
    
    enum Action: Equatable, BindableAction {
        enum ViewAction: Equatable {
            case onChangePasswordButtonTaped
        }
        
        enum DelegateAction: Equatable {
            case didPasswordChanged
        }
        
        enum AlertAction: Equatable {
            case confirmPasswordChange
        }
        
        case view(ViewAction)
        case alert(PresentationAction<AlertAction>)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onChangePasswordButtonTaped:
                    state.alert = AlertState {
                        TextState("确认重置？")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmPasswordChange) {
                            TextState(String(localized:"确定", comment: "Forgot Password Alert"))
                        }
                    }
                    return .none
                }
                
            case .alert(.presented(.confirmPasswordChange)):
                return .send(.delegate(.didPasswordChanged))
                
            case .delegate, .alert:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
