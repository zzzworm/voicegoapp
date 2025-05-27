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
    @Perception.Bindable var store: StoreOf<ProfileFeature>
    private enum BackgroudID { case backgroud1 }
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                    ).id(BackgroudID.backgroud1)
                        .ignoresSafeArea()
                )
                .task {
                    store.send(.fetchUserProfileFromDB)
                    store.send(.fetchUserProfileFromServer)
                }
                .navigationTitle("我的")
                .navigationBarTitleDisplayMode(.inline)
                
            } destination: { store in
                switch store.case {
                case let .setting(store):
                    ProfileSettingView(store: store)
                }
            }
        }
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            store: Store(
                initialState: ProfileFeature.State(),
                reducer: ProfileFeature.init
            )
        )
    }
}
