//
//  ForgotPasswordView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - ForgotPasswordView

struct ForgotPasswordView {
    @Perception.Bindable var store: StoreOf<ForgotPasswordFeature>
}

// MARK: - Views

extension ForgotPasswordView: View {
    
    var body: some View {
        content
            .navigationTitle("忘记密码")
    }
    
    @ViewBuilder private var content: some View {
        VStack {
            Spacer()

            Button("发送验证码", action: {
                store.send(.view(.onChangePasswordButtonTap))
            })
            .buttonStyle(.cta)
        }
        .padding(24)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
