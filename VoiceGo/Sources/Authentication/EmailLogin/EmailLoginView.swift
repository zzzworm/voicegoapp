//
//  LoginView.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 12.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginView

struct EmailLoginView {
    @Perception.Bindable var store: StoreOf<EmailLoginFeature>
}

// MARK: - Views

extension EmailLoginView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        BlurredActivityIndicatorView(
            isShowing: $store.isActivityIndicatorVisible)
        {
            VStack {
                VStack {
                    TextField(
                        "用户名或者邮箱",
                        text: $store.userIdentifier
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.main)
                    
                    SecureField(
                        "••••••••",
                        text: $store.password
                    )
                    .textFieldStyle(.main)
                    
                    HStack {
                        Spacer()
                        Button("忘记密码", action: {
                            store.send(.view(.onForgotPasswordButtonTap))
                        })
                        .buttonStyle(.linkButton)
                    }
                    .padding(.top, 16)
                    
                    Button("确定", action: {
                        store.send(.view(.onSignInButtonTap))
                    })
                    .buttonStyle(.cta)
                    .padding(.top, 24)
                }
                .padding(24)
                
                Spacer()
            }
            .navigationTitle("邮箱&用户名登录")
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
