//
//  RootView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(
                selection: $store.currentTab.sending(\.onTabChanged)
            ) {
                StudyToolListView(
                    store: self.store.scope(
                        state: \.studytoolListState,
                        action: RootFeature.Action
                            .studytoolList
                    )
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("学习")
                }
                .tag(RootFeature.Tab.studytools)
                ProfileView(
                    store: self.store.scope(
                        state: \.profileState,
                        action: \.profile
                    )
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
                .tag(RootFeature.Tab.profile)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .task { await store.send(.task).finish() }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: Store(
                initialState: RootFeature.State(),
                reducer: RootFeature.init
            )
        )
    }
}
