//
//  LoginView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 12.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginView


// MARK: - Views

struct EmailLoginView: View {
    @Perception.Bindable var store: StoreOf<EmailLoginFeature>
    
    enum FocusedField {
            case username, password
        }

    @FocusState private var focusedField: FocusedField?
    
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
                    .focused($focusedField, equals: .username)
                    
                    SecureField(
                        "••••••••",
                        text: $store.password
                    )
                    .textFieldStyle(.main)
                    .focused($focusedField, equals: .password)
                    
                    HStack {
                        Spacer()
                        Button("忘记密码", action: {
                            store.send(.view(.onForgotPasswordButtonTap))
                        })
                        .buttonStyle(.linkButton)
                    }
                    .padding(.top, 16)
                    
                    Button("确定", action: {
                        focusedField = nil
                        store.send(.view(.onSignInButtonTap))
                    })
                    .buttonStyle(.cta)
                    .padding(.top, 24)
                }
                .padding(24)
                .onSubmit {
                            if focusedField == .username {
                                focusedField = .password
                            } else {
                                focusedField = nil
                            }
                        }
                
                Button("账号注册", action: {
                    focusedField = nil
                    store.send(.view(.onSignUpButtonTap))
                })
                .buttonStyle(.cta)
                .padding(.top, 24)
                
                Spacer()
            }
            .navigationTitle("邮箱&用户名登录")
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}




