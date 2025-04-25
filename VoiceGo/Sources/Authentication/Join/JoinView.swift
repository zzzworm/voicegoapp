//
//  LoginOptionsView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 29.08.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginOptionsView

struct JoinView {
    @Perception.Bindable var store: StoreOf<JoinFeature>
}

// MARK: - Views

extension JoinView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    Spacer()
                    
                    Image(systemName: "pencil.slash")
                        .font(.system(size: 100))
                    
                    VStack(spacing: 6) {
                        Text("您的英语AI伴读工具")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                        
                        VStack{
                            Button {
                                store.send(.view(.onClickAuthByTap))
                            } label: {
                                Text("一键登录")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }.background(Color.white)
                                .cornerRadius(8)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            Button {
                                store.send(.view(.onWechatAuthByTap))
                            } label: {
                                Text("微信登录")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }.background(Color.white)
                                .cornerRadius(8)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    Button("Join", action: {
                        store.send(.view(.onJoinButtonTap))
                    })
                    .buttonStyle(.cta)
                }
                .padding(24)
                .navigationTitle("晨读AI英语")
                .modifier(NavigationBarModifier())
            } destination: { store in
                switch store.case {
                case let .emailLogin(store):
                    EmailLoginView(store: store)
                    
                case let .forgotPassword(store):
                    ForgotPasswordView(store: store)
                    
                case let .phoneLogin(store):
                    PhoneLoginView(store: store)
                    
                case let .phoneOTP(store):
                    PhoneOTPView(store: store)
                case let .emailRegister(store):
                    EmailRegisterView(store: store)
                }
            }
            .sheet(
                item: $store.scope(state: \.developedBy, action: \.developedBy)
            ) { developedByStore in
                DevelopedByView(store: developedByStore)
            }
            .sheet(
                item: $store.scope(state: \.loginOptions, action: \.loginOptions)
            ) { loginOptionsStore in
                LoginOptionsView(store: loginOptionsStore)
            }
        }
    }
}

