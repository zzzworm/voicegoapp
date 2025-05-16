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
        content.enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            BlurredActivityIndicatorView(
                isShowing: $store.isActivityIndicatorVisible)
            {
                VStack {
                    VStack {
                        AuthTextField(
                            icon: Image(systemName: "at"),
                            placeholder: "Username",
                            isSecure: false,
                            keyboardType: .emailAddress,
                            text: $store.userIdentifier
                        )
                        .focused($focusedField, equals: .username)
                        AuthTextField(
                            icon: Image(systemName: "lock"),
                            placeholder: "Password",
                            isSecure: true,
                            keyboardType: .default,
                            text: $store.password
                        )
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
                .background(
                    
                    Image("splash_background")
                )
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Preview

struct EmailLoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
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
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
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
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
            
    }
}




