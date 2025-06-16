//
//  NoNetworkView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 20.06.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - NoNetworkView

struct NoNetworkView: View {
    let store: StoreOf<NoNetwork>

    var body: some View {
        content
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif

    @ViewBuilder private var content: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Base.oops")
                .font(Font.title)
                .multilineTextAlignment(.center)

            Image("wifi.exclamationmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128, alignment: .center)

            Text("Base.noNetworkConnection")
                .font(Font.title3)
                .multilineTextAlignment(.center)

            Button("Base.ok") {
                store.send(.onOkTapped)
            }
            .buttonStyle(.cta)

            Spacer()
        }
        .padding([.leading, .trailing], 48)
        .padding(.top, 64)
    }
}
