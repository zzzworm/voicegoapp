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
        var aiTeacher: AITeacher {
            return aiTeacherList.first(where: { $0.id == selectedTeacherId }) ?? aiTeacherList.first!
        }
        var aiTeacherList: IdentifiedArrayOf<AITeacher> = []
        var selectedTeacherId: Int?

        init(aiTeacherList: IdentifiedArrayOf<AITeacher> = [], selectedTeacherId: Int?) {
            self.aiTeacherList = aiTeacherList
            self.selectedTeacherId = selectedTeacherId ?? aiTeacherList.first?.id
        }
    }
    @CasePathable
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case selectTeacher(AITeacher)
        case tapTalkToTeacher(AITeacher)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .selectTeacher(let teacher):
                state.selectedTeacherId = teacher.id
                return .none

            case .tapTalkToTeacher(let teacher):

                return .none

            case .binding:
                return .none
            }
        }
    }
}
