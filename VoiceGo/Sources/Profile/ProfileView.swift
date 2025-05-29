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
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                
                ZStack {
                    VStack{
                        if let profile = store.state.profile{
                            
                            ProfileCell(profile: profile){
                                store.send(.view(.onEditProfileTapped))
                            }
                        }
                        let listItems = Group{
                            HStack{
                                Button(action: {
                                    store.send(.view(.onSettingTapped))
                                }) {
                                    HStack{
                                        Image(systemName: "gearshape")
                                            .foregroundColor(.primary)
                                        Text("设置")
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            HStack{
                                Button(action: {
                                    store.send(.view(.onSettingTapped))
                                }) {
                                    HStack{
                                        Image(systemName: "bell")
                                            .foregroundColor(.primary)
                                        Text("反馈/举报")
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            HStack {
                                Spacer()
                                Text("版本 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        if #available(iOS 17.0, *) {
                            List{
                                listItems
                            }
                            .scrollContentBackground(.hidden)
                            .padding(0)
                            .listRowInsets(EdgeInsets()) // 移除默认内边距
                            .environment(\.defaultMinListRowHeight, 56)
                            .contentMargins(.top, 0)
                        }
                        else{
                            List{
                                Section{
                                    listItems
                                }
                                header: {
                                    Spacer(minLength: 0).listRowInsets(EdgeInsets())
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .padding(0)
                            .listRowInsets(EdgeInsets()) // 移除默认内边距
                            .environment(\.defaultMinListRowHeight, 56)
                            .environment(\.defaultMinListHeaderHeight, 0)
                        }
                        
                        if store.state.isLoading {
                            ProgressView()
                        }
                        Spacer()
                    }
                    
                }
                .commonBackground()
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
                case let .edit(store):
                    ProfileEditView(store: store)
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
