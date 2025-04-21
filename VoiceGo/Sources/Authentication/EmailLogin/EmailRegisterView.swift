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
    
    enum FocusedField {
            case username,email, password, retype
        }

    @FocusState private var focusedField: FocusedField?
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
                    .focused($focusedField, equals: .username)
                    
                    TextField(
                        "邮箱",
                        text: $store.email
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.main)
                    .focused($focusedField, equals: .email)
                    
                    SecureField(
                        "••••••••",
                        text: $store.password
                    )
                    .textFieldStyle(.main)
                    .focused($focusedField, equals: .password)
                    
                    SecureField(
                        "••••••••",
                        text: $store.retypePassword
                    )
                    .textFieldStyle(.main)
                    .focused($focusedField, equals: .retype)
                    
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
            .navigationTitle("注册")
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}




