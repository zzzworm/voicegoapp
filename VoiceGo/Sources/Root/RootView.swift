//
//  RootView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(
                selection: $store.currentTab.sending(\.onTabChanged)
            ) {
                AITeacherListView(
                    store: self.store.scope(
                        state: \.tearchListState,
                        action: RootFeature.Action
                            .tearchList
                    )
                )
                .tabItem {
                    if store.currentTab == .tearchList {
                        Image(systemName: "ellipses.bubble.fill")
                    } else {
                        Image(systemName: "ellipses.bubble")
                    }
                    Text("AI教练")
                }
                .tag(RootFeature.Tab.tearchList)
                ConversationSceneListView(
                    store: self.store.scope(
                        state: \.conversationSceneListState,
                        action: RootFeature.Action.conversationSceneList
                    )
                )
                .tabItem {
                    if store.currentTab == .conversationSceneList {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                    } else {
                        Image(systemName: "bubble.left.and.bubble.right")
                    }
                    Text("情景对话")
                }
                .tag(RootFeature.Tab.conversationSceneList)

                StudyToolListView(
                    store: self.store.scope(
                        state: \.studytoolListState,
                        action: RootFeature.Action
                            .studytoolList
                    )
                )
                .tabItem {
                    if store.currentTab == .studytools {
                        Image(systemName: "briefcase.fill")
                    } else {
                        Image(systemName: "briefcase")
                    }
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
                    if store.currentTab == .profile {
                        Image(systemName: "person.fill")
                    } else {
                        Image(systemName: "person")
                    }
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
