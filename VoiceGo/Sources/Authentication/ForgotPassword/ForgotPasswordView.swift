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
    @Bindable var store: StoreOf<ForgotPasswordFeature>
    
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
                Image("splash_logo").padding(42)
                AuthTextField(
                    icon: Image(systemName: "envelope"),
                    placeholder: "Email",
                    isSecure: false,
                    keyboardType: .emailAddress,
                    text: $store.userIdentifier
                )
                HStack{
                    Text("OR").font(.caption).padding(6)
                    Spacer()
                }
                AuthTextField(
                    icon: Image(systemName: "at"),
                    placeholder: "Username",
                    isSecure: false,
                    keyboardType: .emailAddress,
                    text: $store.userIdentifier
                )
                .focused($focused)
                Spacer()
                Button("发送验证码", action: {
                    store.send(.view(.onChangePasswordButtonTaped))
                })
                .buttonStyle(CTAButtonStyle(isSelected: true))
                    .padding(.bottom, 12)
            }
            .padding(20)
            .alert($store.scope(state: \.alert, action: \.alert))
            .commonBackground()
        }
    }
}
