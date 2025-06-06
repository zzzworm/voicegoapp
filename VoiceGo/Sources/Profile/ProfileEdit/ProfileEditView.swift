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
                    profileImageSection
                    basicInfoSection
                    studySettingsSection
                }
                .environment(\.defaultMinListHeaderHeight, 0)
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
                .sheet(isPresented: $store.isSexPickerPresented) {
                    sexPickerView
                }
                .sheet(isPresented: $store.isEngLevelPickerPresented) {
                    engLevelPickerView
                }
                .sheet(isPresented: $store.isWordLevelPickerPresented) {
                    wordLevelPickerView
                }
                .sheet(isPresented: $store.isUserRolePickerPresented) {
                    userRolePickerView
                }
            }
        }
    }
    
    // MARK: - Profile Image Section
    @ViewBuilder private var profileImageSection: some View {
        Section {
            HStack {
                Spacer()
                PhotosPicker(selection: $store.selectedImage) {
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
    }
    
    // MARK: - Basic Info Section
    @ViewBuilder private var basicInfoSection: some View {
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
                    Text(store.sexToChange.localizedDescription)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Study Settings Section
    @ViewBuilder private var studySettingsSection: some View {
        Section("学习设置") {
            // English Level
            Button(action: {
                store.send(.view(.toggleEngLevelPicker(true)))
            }) {
                HStack {
                    Text("英语水平")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(store.engLevelToChange.localizedDescription)
                        .foregroundColor(.gray)
                }
            }
            
            // Word Level
            Button(action: {
                store.send(.view(.toggleWordLevelPicker(true)))
            }) {
                HStack {
                    Text("词汇级别")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(store.wordLevelToChange.localizedDescription)
                        .foregroundColor(.gray)
                }
            }
            
            // Study Goal
            HStack {
                Text("学习目标")
                    .foregroundColor(.primary)
                Spacer()
                TextField("学习目标", text: $store.studyGoalToChange)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.gray)
            }
            
            // User Role
            Button(action: {
                store.send(.view(.toggleUserRolePicker(true)))
            }) {
                HStack {
                    Text("用户角色")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(store.userRoleToChange.localizedDescription)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Picker Views
    
    @ViewBuilder private var sexPickerView: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(UserProfile.Sex.allCases, id: \.self) { sex in
                        Button(action: { store.send(.view(.sexSelected(sex))) }) {
                            HStack {
                                Text(sex.localizedDescription)
                                Spacer()
                                if sex == store.sexToChange {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Spacer(minLength: 0).listRowInsets(EdgeInsets())
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .navigationTitle("选择性别")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        store.send(.view(.toggleSexPicker(false)))
                    }
                }
            }
        }
        .presentationDetents([.height(160)])
    }
    
    @ViewBuilder private var engLevelPickerView: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(UserStudySetting.EngLevel.allCases, id: \.self) { level in
                        Button(action: { store.send(.view(.engLevelSelected(level))) }) {
                            HStack {
                                Text(level.localizedDescription)
                                Spacer()
                                if level == store.engLevelToChange {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Spacer(minLength: 0).listRowInsets(EdgeInsets())
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .navigationTitle("选择英语水平")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        store.send(.view(.toggleEngLevelPicker(false)))
                    }
                }
            }
        }
        .presentationDetents([.height(240)])
    }
    
    @ViewBuilder private var wordLevelPickerView: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(UserStudySetting.WordLevel.allCases, id: \.self) { level in
                        Button(action: { store.send(.view(.wordLevelSelected(level))) }) {
                            HStack {
                                Text(level.localizedDescription)
                                Spacer()
                                if level == store.wordLevelToChange {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Spacer(minLength: 0).listRowInsets(EdgeInsets())
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .navigationTitle("选择词汇级别")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        store.send(.view(.toggleWordLevelPicker(false)))
                    }
                }
            }
            .presentationDetents([.height(580)])
        }
    }
    
    @ViewBuilder private var userRolePickerView: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(UserStudySetting.UserRole.allCases, id: \.self) { role in
                        Button(action: { store.send(.view(.userRoleSelected(role))) }) {
                            HStack {
                                Text(role.localizedDescription)
                                Spacer()
                                if role == store.userRoleToChange {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Spacer(minLength: 0).listRowInsets(EdgeInsets())
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .navigationTitle("选择用户角色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        store.send(.view(.toggleUserRolePicker(false)))
                    }
                }
            }
        }
        .presentationDetents([.height(380)])
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
