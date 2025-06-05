//
//  ProfileDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileSettingFeature {
    @Dependency(\.apiClient) var apiClient
    
    @ObservableState
    struct State : Equatable{
        @Presents var alert: AlertState<Action>?
    }
    
    enum Action: BindableAction,Equatable {
        
        enum Delegate: Equatable {
            case didLogout
        }
        
        case confirmLogout
        case logout
        case alert(PresentationAction<Action>)
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .logout:
                state.alert = AlertState {
                    TextState("确定要退出登录吗？")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmLogout) {
                        TextState("确定")
                    }
                    ButtonState(role: .cancel) {
                        TextState("取消")
                    }
                }
                return .none
            case .alert(.presented(.confirmLogout)):
                return .send(.delegate(.didLogout))
            case .alert:
                return .none
            case .delegate(_):
                return .none
            case .binding(_):
                return .none
            case .confirmLogout:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
