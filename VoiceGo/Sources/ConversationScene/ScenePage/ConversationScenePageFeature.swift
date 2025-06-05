//
//  TeacherPageFeature.swift
//  VoiceGo
//
//  Created by admin on 2025/6/5.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import Foundation
import ComposableArchitecture

// Placeholder for the detail feature
@Reducer
struct ConversationScenePageFeature {
    @ObservableState
    struct State: Equatable {
        var conversationScene: ConversationScene
        // Add other state properties for the detail view if needed
    }
    @CasePathable
    enum Action: Equatable,BindableAction {
        case binding(BindingAction<State>)
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Handle actions
            return .none
        }
    }
}
