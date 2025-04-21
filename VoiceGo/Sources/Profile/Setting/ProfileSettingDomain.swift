//
//  ProfileDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import ComposableArchitecture

struct ProfileSettingDomain: Reducer {
    @Dependency(\.apiClient) var apiClient

    struct State: Equatable {
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

        case logout
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .logout:
            return .none
        }
    }
}
