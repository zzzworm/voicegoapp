//
//  DevelopedByView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 13.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - DevelopedByView

struct DevelopedByView: View {
    let store: StoreOf<DevelopedByFeature>

    var body: some View {
        content
            .onAppear { self.store.send(.view(.onViewAppear)) }

    }

    @ViewBuilder private var content: some View {
        VStack(alignment: .leading) {
            Text("Developed By")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding(.top, 24)

            ScrollView {
                Text(store.text)
                    .font(.body)
            }
        }
        .padding(24)

        Button("continue", action: {
            store.send(.view(.onAcceptTap))
        })
        .buttonStyle(.cta)
        .padding(24)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
