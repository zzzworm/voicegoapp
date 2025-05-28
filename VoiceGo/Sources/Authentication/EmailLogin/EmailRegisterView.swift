//
//  LoginView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 12.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginView

struct EmailRegisterView : View {
    @Perception.Bindable var store: StoreOf<EmailRegisterFeature>
    
    enum FocusedField {
            case username,email, password, retype
        }

    @FocusState private var focusedField: FocusedField?

    
    var body: some View {
        content
        .enableInjection()
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
                    Image(systemName: "pencil.slash")
                        .font(.system(size: 40))
                    
                    VStack {
                        AuthTextField(
                            icon: Image(systemName: "envelope"),
                            placeholder: "Email",
                            isSecure: false,
                            keyboardType: .emailAddress,
                            text: $store.email
                        )
                        AuthTextField(
                            icon: Image(systemName: "at"),
                            placeholder: "Username",
                            isSecure: false,
                            keyboardType: .default,
                            text: $store.username
                        )
                        AuthTextField(
                            icon: Image(systemName: "lock"),
                            placeholder: "Password",
                            isSecure: true,
                            keyboardType: .default,
                            text: $store.password
                        )
                        
                        AuthTextField(
                            icon: Image(systemName: "lock"),
                            placeholder: "Password",
                            isSecure: true,
                            keyboardType: .default,
                            text: $store.retypePassword
                        )
                        
                        Button("确定", action: {
                            focusedField = nil
                            store.send(.view(.onConfirmButtonTap))
                        })
                        .buttonStyle(.cta)
                        .padding(.top, 24)
                    }
                    .padding(24)
                    .onSubmit {
                        if focusedField == .username {
                            focusedField = .email
                        } else if focusedField == .email {
                            focusedField = .password
                        }else if focusedField == .password {
                            focusedField = .retype
                        }
                        else {
                            focusedField = nil
                        }
                    }
                    
                    Spacer()
                }
                .commonBackground()
                .navigationTitle("注册")
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}


// MARK: - Preview

struct EmailRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            EmailRegisterView(
                store: Store(
                    initialState: EmailRegisterFeature.State(
                        isActivityIndicatorVisible: false,
                        username: "StrapiUser1",
                        email: "StrapiUser1@example.com",
                        password: "password123",
                        retypePassword: "password123",
                        alert: nil
                    )){
                        EmailRegisterFeature()
                    }
            )
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            EmailRegisterView(
                store: Store(
                    initialState: EmailRegisterFeature.State(
                        isActivityIndicatorVisible: false,
                        username: "StrapiUser1",
                        email: "StrapiUser1@example.com",
                        password: "password123",
                        retypePassword: "password123",
                        alert: nil
                    )){
                        EmailRegisterFeature()
                    }
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}


