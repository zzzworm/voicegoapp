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
        var selectedTab = Tab.studytools
        var studytoolListState = StudyToolListDomain.State()
        var profileState = ProfileDomain.State()
    }
    
    enum Tab {
        case studytools
        case profile
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case studytoolList(StudyToolListDomain.Action)
        case profile(ProfileDomain.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.studytoolListState, action: /Action.studytoolList) {
            StudyToolListDomain()
        }
        Scope(state: \.profileState, action: /Action.profile) {
            ProfileDomain()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .studytoolList:
                return .none
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .profile:
                return .none
            }
        }
    }
}
