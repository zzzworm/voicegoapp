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

struct ProfileView: View {
    @Perception.Bindable var store: StoreOf<ProfileDomain>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
        
            NavigationView {
                ZStack {
                    List{

                        HStack{
                            Button(action: {
                                store.send(.view(.onSettingTapped))
                            }) {
                                Text("设置")
                            }
                            Spacer()
                        }
                    }
                    if store.state.isLoading {
                        ProgressView()
                    }
                    
                }
                .task {
                    store.send(.fetchUserProfileFromDB)
                    store.send(.fetchUserProfileFromServer)
                }
                .navigationTitle("我的")
                .navigationBarTitleDisplayMode(.inline)
            }
        
        } destination: { store in
                    switch store.case {
                    case let .setting(store):
                        ProfileSettingView(store: store)
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
