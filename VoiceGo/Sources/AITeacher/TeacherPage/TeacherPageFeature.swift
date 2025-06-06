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
struct AITeacherPageFeature {
    @ObservableState
    struct State: Equatable {
        var aiTeacher: AITeacher
        var aiTeacherList: IdentifiedArrayOf<AITeacher> = []
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
