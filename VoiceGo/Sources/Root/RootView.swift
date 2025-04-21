//
//  RootView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootDomain>
    
    var body: some View {
            TabView(
                selection: $store.currentTab.sending(\.onTabChanged)
            ) {
                StudyToolListView(
                    store: self.store.scope(
                        state: \.studytoolListState,
                        action: RootDomain.Action
                            .studytoolList
                    )
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("学习")
                }
                .tag(RootDomain.Tab.studytools)
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
                .tag(RootDomain.Tab.profile)
            }
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: Store(
                initialState: RootDomain.State(),
                reducer: RootDomain.init
            )
        )
    }
}
