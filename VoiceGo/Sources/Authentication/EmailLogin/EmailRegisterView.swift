//
//  LoginView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 12.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginView

struct EmailRegisterView {
    @Perception.Bindable var store: StoreOf<EmailRegisterFeature>
}

// MARK: - Views

extension EmailRegisterView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        BlurredActivityIndicatorView(
            isShowing: $store.isActivityIndicatorVisible)
        {
            VStack {
                Image(systemName: "pencil.slash")
                        .font(.system(size: 40))
                
                VStack {
                    TextField(
                        "用户名",
                        text: $store.username
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.main)
                    
                    TextField(
                        "邮箱",
                        text: $store.email
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
                    
                    SecureField(
                        "••••••••",
                        text: $store.retypePassword
                    )
                    .textFieldStyle(.main)
                    
                    Button("确定", action: {
                        store.send(.view(.onConfirmButtonTap))
                    })
                    .buttonStyle(.cta)
                    .padding(.top, 24)
                }
                .padding(24)
                
                
                Spacer()
            }
            .navigationTitle("注册")
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}




