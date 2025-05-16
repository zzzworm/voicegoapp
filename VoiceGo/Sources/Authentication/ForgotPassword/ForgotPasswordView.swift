//
//  ForgotPasswordView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - ForgotPasswordView

struct ForgotPasswordView : View {
    @Perception.Bindable var store: StoreOf<ForgotPasswordFeature>
    
    @FocusState private var focused: Bool
    
    var body: some View {
        content
            .navigationTitle("忘记密码")
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            VStack {
                Spacer()
                AuthTextField(
                    icon: Image(systemName: "at"),
                    placeholder: "Username",
                    isSecure: false,
                    keyboardType: .emailAddress,
                    text: $store.userIdentifier
                )
                .focused($focused)
                Button("发送验证码", action: {
                    store.send(.view(.onChangePasswordButtonTap))
                })
                .buttonStyle(.cta)
            }
            .padding(24)
            .alert($store.scope(state: \.alert, action: \.alert))
            .background(
                
                Image("splash_background")
            )
        }
    }
}
