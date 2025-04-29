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
                    List{

#if DEBUG
                    NavigationLink(destination: ConsoleView()) {
                        Text("Console")
                    }
#endif
                    
                        HStack{
                            Button(action: {
                                store.send(.logout)
                            }) {
                                Text("退出登录")
                            }
                            Spacer()
                        }
                    }
                    if viewStore.isLoading {
                        ProgressView()
                    }
                }
                .navigationTitle("我的")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
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
