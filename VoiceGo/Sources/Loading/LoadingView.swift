//
//  LoadingView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 11.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoadingView

struct LoadingView {
    @Perception.Bindable var store: StoreOf<LoadingFeature>
}

// MARK: - Views@Perception.

extension LoadingView: View {

    var body: some View {
        content
            .onAppear { store.send(.view(.onViewAppear)) }
    }

    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            VStack(spacing: 10) {
                Text("S1").font(Font.title2)
                ProgressViewWrapper(progress: $store.progress)
            }
        }
    }
}
