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
            .background()
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif

    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            ZStack{
                Image(VoiceGoAsset.Assets.splashBackground.name)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: 50) {
                    Image("splash_logo")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    ProgressViewWrapper(progress: $store.progress)
                }
            }
        }
    }
}

//add preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(
            store: Store(
                initialState: LoadingFeature.State(),
                reducer: LoadingFeature.init
            )
        )
    }
}
