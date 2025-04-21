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
    let store: StoreOf<ProfileSettingDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
#if DEBUG
                    NavigationLink(destination: ConsoleView()) {
                        Text("Console")
                    }
#endif
                    
                    if viewStore.isLoading {
                        ProgressView()
                    }
                }
                .task {
                    viewStore.send(.fetchUserProfile)
                }
                .navigationTitle("我的")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView(
            store: Store(
                initialState: ProfileSettingDomain.State(),
                reducer: ProfileSettingDomain.init
            )
        )
    }
}
