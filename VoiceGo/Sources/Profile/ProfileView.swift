//
//  ProfileView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import SwiftUI
import ComposableArchitecture
import PulseUI

struct ProfileView: View {
    let store: StoreOf<ProfileDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
                    NavigationLink(destination: ConsoleView()) {
                        Text("Console")
                    }
                    
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            store: Store(
                initialState: ProfileDomain.State(),
                reducer: ProfileDomain.init
            )
        )
    }
}
