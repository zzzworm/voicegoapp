//
//  LoginOptionsView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 29.08.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginOptionsView

struct JoinView: View {
    @Bindable var store: StoreOf<JoinFeature>

    var body: some View {
        content
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif

    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {

                    VStack {
                        Text("您的英语AI伴读工具")
                            .foregroundColor(.appMainColor)
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .fontWeight(.bold)
                            .stroke(color: .white, lineWidth: 2)
                            .padding()
                        Spacer()
                        VStack(spacing: 6) {

                            VStack {
                                let selectedStyle = CTAButtonStyle(isSelected: true)
                                Button {
                                    store.send(.view(.onClickAuthByTap))
                                } label: {
                                    Text("一键登录")
                                        .font(.headline)
                                }
                                .buttonStyle(selectedStyle)
                                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))

                                Button {
                                    store.send(.view(.onWechatAuthByTap))
                                } label: {
                                    Text("微信登录")
                                        .font(.headline)
                                }
                                .buttonStyle(.cta)
                                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                            }
                        }
                        .padding(.top, 24)

                        Button {
                            store.send(.view(.onJoinButtonTap))
                        }
                        label: {
                            Text("其他登录")
                                .font(.headline)
                                .underline()
                                .foregroundColor(.white)
                        }
                        .padding(20)

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Image(VoiceGoAsset.Assets.loginBackground.name)
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .scaledToFill()
                    )

                .navigationTitle("晨读AI英语")
                .navigationBarTitleDisplayMode(.inline)

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
