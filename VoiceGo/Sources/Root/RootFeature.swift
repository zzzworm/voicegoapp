//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {

    @ObservableState
    struct State : Equatable {
        var currentTab = Tab.studytools
        var studytoolListState = StudyToolsFeature.State()
        var profileState = ProfileFeature.State()
        var notifications = NotificationsFeature.State()
    }
    
    enum Tab: Int, CaseIterable {
        case favourites
        case chat
        case studytools
        case profile
    }
    
    enum Action: BindableAction {
        case onTabChanged(Tab)
        case addNotifications(NotificationItem)
                
        case studytoolList(StudyToolsFeature.Action)
        case profile(ProfileFeature.Action)
        case notifications(NotificationsFeature.Action)
                
        enum Delegate: Equatable {
                    case didLogout
        }
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.studytoolListState, action: /Action.studytoolList) {
            StudyToolsFeature()
        }
        Scope(state: \.profileState, action: /Action.profile) {
            ProfileFeature()
        }
        Scope(state: \.notifications, action: /Action.notifications) {
                    NotificationsFeature()
                }
        Reduce<State, Action> { state, action in
            switch action {
            case .studytoolList:
                return .none
            case .onTabChanged(let tab):
                state.currentTab = tab
                return .none
            case .profile(.delegate(.didLogout)):
                return .send(.delegate(.didLogout))
            case .profile:
                return .none
            case let .addNotifications(notification):
                            state.notifications.items.append(notification)
                            return .none
            case .notifications(.delegate(.didAccountNotificationTapped)):
                state.currentTab = .profile
                            return .none
            case .binding:
                return .none
            case .notifications(_):
                return .none
            case .notifications(.internal(_)):
                return .none
            case .notifications(.alert(_)):
                return .none
            case .delegate(_):
                return .none
            }
        }
    }
}
