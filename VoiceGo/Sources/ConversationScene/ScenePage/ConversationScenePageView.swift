//
//  TeacherPageView.swift
//  VoiceGo
//
//  Created by admin on 2025/6/5.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//
import SwiftUI
import ComposableArchitecture

struct ConversationScenePageView: View {
    let store: StoreOf<ConversationScenePageFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("AI Teacher Details: \(store.conversationScene.name)")
                // Add more detail view content here
            }
            .navigationTitle(store.conversationScene.name)
        }
    }
}
