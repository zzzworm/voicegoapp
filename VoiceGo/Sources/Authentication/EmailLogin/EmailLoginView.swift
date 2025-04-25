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
        WithPerceptionTracking {
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
                            Button("账号注册", action: {
                                focusedField = nil
                                store.send(.view(.onSignUpButtonTap))
                            })
                            .buttonStyle(.linkButton)
                            Spacer()
                            Button("忘记密码", action: {
                                focusedField = nil
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
                    
                    Spacer()
                }
                .navigationTitle("登录")
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Preview

struct EmailLoginView_Previews: PreviewProvider {
    static var previews: some View {
        EmailLoginView(
            store: Store(
                initialState: EmailLoginFeature.State(
                    isActivityIndicatorVisible: false,
                    userIdentifier: "StrapiUser1",
                    password: "password123",
                    alert: nil
                )){
                    EmailLoginFeature()
                }
        )
    }
}




