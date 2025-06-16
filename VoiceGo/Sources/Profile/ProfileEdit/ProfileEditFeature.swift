import SwiftUI
import ComposableArchitecture
import PhotosUI

@Reducer
struct ProfileEditFeature {
    @ObservableState
    struct State: Equatable {
        var profile: UserProfile
        var usernameToChange: String = ""
        var cityToChange: String = ""
        var sexToChange: UserProfile.Sex = .male
        var engLevelToChange: UserStudySetting.EngLevel = .primary
        var wordLevelToChange: UserStudySetting.WordLevel = .primarySchool
        var studyGoalToChange: String = ""
        var userRoleToChange: UserStudySetting.UserRole = .schoolStudent
        var isLoading = false
        var selectedImage: PhotosPickerItem?
        var displayImage: UIImage?
        var isSexPickerPresented = false
        var isEngLevelPickerPresented = false
        var isWordLevelPickerPresented = false
        var isUserRolePickerPresented = false
        @Presents var alert: AlertState<Never>?

        public init(profile: UserProfile, selectedImage: PhotosPickerItem? = nil, displayImage: UIImage? = nil) {
            self.profile = profile
            self.usernameToChange = profile.username
            self.cityToChange = profile.city ?? ""
            self.sexToChange = profile.sex

            // Initialize learning settings from profile or use defaults
            if let studySetting = profile.study_setting {
                self.engLevelToChange = studySetting.eng_level
                self.wordLevelToChange = studySetting.word_level
                self.studyGoalToChange = studySetting.study_goal
                self.userRoleToChange = studySetting.role
            } else {
                self.engLevelToChange = .primary
                self.wordLevelToChange = .primarySchool
                self.studyGoalToChange = ""
                self.userRoleToChange = .schoolStudent
            }

            self.isLoading = false
            self.selectedImage = selectedImage
            self.displayImage = displayImage
            self.isSexPickerPresented = false
            self.isEngLevelPickerPresented = false
            self.isWordLevelPickerPresented = false
            self.isUserRolePickerPresented = false
            self.alert = nil
        }
    }

    enum Action: BindableAction {
        enum ViewAction: Equatable {
            case onSaveButtonTap
            case imageSelected(PhotosPickerItem?)
            case loadImageContent
            case imageLoaded(UIImage?)
            case sexSelected(UserProfile.Sex)
            case toggleSexPicker(Bool)
            case engLevelSelected(UserStudySetting.EngLevel)
            case toggleEngLevelPicker(Bool)
            case wordLevelSelected(UserStudySetting.WordLevel)
            case toggleWordLevelPicker(Bool)
            case userRoleSelected(UserStudySetting.UserRole)
            case toggleUserRolePicker(Bool)
            case studyGoalChanged(String)
        }

        enum InternalAction: Equatable {
            case updateProfileResponse(TaskResult<UserProfile>)
        }

        enum Delegate: Equatable {
            case didUpdateProfile(UserProfile)
        }

        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
        case alert(PresentationAction<Never>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .view(.onSaveButtonTap):
                state.isLoading = true
                return .run { [state] send in
                    do {
                        // Create or update study setting
                        let studySetting = UserStudySetting(
                            id: state.profile.study_setting?.id ?? 0,
                            eng_level: state.engLevelToChange,
                            word_level: state.wordLevelToChange,
                            study_goal: state.studyGoalToChange,
                            role: state.userRoleToChange
                        )

                        // Update the profile with study settings
                        let updatedProfile = try await apiClient.updateUserProfile(
                            state.profile.copy(
                                city: state.cityToChange,
                                username: state.usernameToChange,
                                sex: state.sexToChange,
                                study_setting: studySetting
                            )
                        )

                        await send(.internal(.updateProfileResponse(.success(updatedProfile))))
                    } catch {
                        await send(.internal(.updateProfileResponse(.failure(error))))
                    }
                }

            case .view(.imageSelected(let selectedImage)):
                state.selectedImage = selectedImage
                return .send(.view(.loadImageContent))

            case .view(.loadImageContent):
                guard let image = state.selectedImage else { return .none }
                return .run { send in
                    if let data = try? await image.loadTransferable(type: Data.self) {
                        await send(.view(.imageLoaded(UIImage(data: data))))
                    }
                }

            case .view(.imageLoaded(let image)):
                state.displayImage = image
                return .none

            case .view(.sexSelected(let sex)):
                state.sexToChange = sex
                return .none

            case .view(.toggleSexPicker(let isPresented)):
                state.isSexPickerPresented = isPresented
                return .none

            case .view(.engLevelSelected(let level)):
                state.engLevelToChange = level
                return .none

            case .view(.toggleEngLevelPicker(let isPresented)):
                state.isEngLevelPickerPresented = isPresented
                return .none

            case .view(.wordLevelSelected(let level)):
                state.wordLevelToChange = level
                return .none

            case .view(.toggleWordLevelPicker(let isPresented)):
                state.isWordLevelPickerPresented = isPresented
                return .none

            case .view(.userRoleSelected(let role)):
                state.userRoleToChange = role
                return .none

            case .view(.toggleUserRolePicker(let isPresented)):
                state.isUserRolePickerPresented = isPresented
                return .none

            case .view(.studyGoalChanged(let goal)):
                state.studyGoalToChange = goal
                return .none

            case .internal(.updateProfileResponse(.success(let profile))):
                state.isLoading = false
                return .send(.delegate(.didUpdateProfile(profile)))

            case .internal(.updateProfileResponse(.failure)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("更新失败")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("确定")
                    }
                } message: {
                    TextState("请稍后重试")
                }
                return .none

            case .delegate:
                return .none

            case .binding:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
