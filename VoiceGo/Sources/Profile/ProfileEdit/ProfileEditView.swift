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
//                        TextField("昵称", text: viewStore.profile.username)
//                            .textContentType(.nickname)
//                        
//                        TextField("城市", text: viewStore.profile.city)
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
