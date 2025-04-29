//
//  LoadingView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 11.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoadingView

struct LoadingView  : View {
    @Perception.Bindable var store: StoreOf<LoadingFeature>


    var body: some View {
        content
            .onAppear { store.send(.view(.onViewAppear)) }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif

    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            VStack(spacing: 10) {
                Text("S1").font(Font.title2)
                ProgressViewWrapper(progress: $store.progress)
            }
        }
    }
}
