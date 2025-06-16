//
//  ProfileView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import SwiftUI
import ComposableArchitecture
#if DEBUG
import PulseUI
#endif

struct ProfileSettingView: View {
    @Bindable var store: StoreOf<ProfileSettingFeature>

    var body: some View {
        content
            .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif

    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            WithViewStore(self.store, observe: { $0 }) { _ in
                NavigationView {
                    ZStack {
                        List {

#if DEBUG
                            NavigationLink(destination: ConsoleView()) {
                                Text("Console")
                            }
#endif

                            HStack {
                                Button(action: {
                                    store.send(.logout)
                                }) {
                                    Text("退出登录")
                                }
                                Spacer()
                            }
                        }
                    }
                    .navigationTitle("设置")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .alert($store.scope(state: \.alert, action: \.alert))
            }
        }
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView(
            store: Store(
                initialState: ProfileSettingFeature.State(),
                reducer: ProfileSettingFeature.init
            )
        )
    }
}
