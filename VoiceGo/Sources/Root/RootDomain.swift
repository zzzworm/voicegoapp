//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture

struct RootDomain: Reducer {
    struct State: Equatable {
        var currentTab = Tab.studytools
        var studytoolListState = StudyToolListDomain.State()
        var profileState = ProfileDomain.State()
        var notifications = NotificationsFeature.State()
    }
    
    enum Tab {
        case favourites
        case chat
        case studytools
        case profile
    }
    
    enum Action: Equatable, BindableAction {
        case onTabChanged(Tab)
        case addNotifications(Notification)
                
        case studytoolList(StudyToolListDomain.Action)
        case profile(ProfileDomain.Action)
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
            StudyToolListDomain()
        }
        Scope(state: \.profileState, action: /Action.profile) {
            ProfileDomain()
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
