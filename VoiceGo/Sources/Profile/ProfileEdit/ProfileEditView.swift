import SwiftUI
import ComposableArchitecture
import PhotosUI

struct ProfileEditView: View {
    @Perception.Bindable var store: StoreOf<ProfileEditFeature>
    
    var body: some View {
        content
            .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                Form {
                    Section {
                        HStack {
                            Spacer()
                            PhotosPicker(selection: viewStore.binding(
                                get: \.selectedImage,
                                send: { .view(.imageSelected($0)) }
                            )) {
                                if let image = store.displayImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(url: URL(string: store.profile.userIconUrl ?? "")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                }
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    Section("基本信息") {
                        TextField("昵称", text: $store.usernameToChange)
                            .textContentType(.nickname)
                        TextField("城市", text: $store.cityToChange)
                        Button(action: {
                            store.send(.view(.toggleSexPicker(true)))
                        }) {
                            HStack {
                                Text("性别")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(store.profile.sex.localizedDescription)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("编辑资料")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("保存") {
                            store.send(.view(.onSaveButtonTap))
                        }
                    }
                }
                .sheet(isPresented: $store.isSexPickerPresented) {
                    NavigationStack {
                        
                        List{
                            Section{
                                ForEach(UserProfile.Sex.allCases, id: \.self) { sex in
                                    Button(action: { store.send(.view(.sexSelected(sex))) }) {
                                        HStack {
                                            Text(sex.localizedDescription)
                                            Spacer()
                                            if sex == store.profile.sex {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            }
                            header: {
                                Spacer(minLength: 0).listRowInsets(EdgeInsets())
                            }
                        }
                        .environment(\.defaultMinListHeaderHeight, 0)
                        .navigationTitle("选择性别")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("取消") {
                                    store.send(.view(.toggleSexPicker(false)))
                                }
                            }
                        }
                    }
                    .presentationDetents([.height(160)]) // 设置固定高度
                        
                }
                .alert($store.scope(state: \.alert, action: \.alert))
                .disabled(store.isLoading)
                .overlay {
                    if store.isLoading {
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(
            store: Store(
                initialState: ProfileEditFeature.State(
                    profile: .sample
                )
            ) {
                ProfileEditFeature()
            }
        )
    }
}
