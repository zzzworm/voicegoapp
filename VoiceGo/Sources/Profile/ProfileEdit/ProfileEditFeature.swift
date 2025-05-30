import SwiftUI
import ComposableArchitecture
import PhotosUI

@Reducer
struct ProfileEditFeature {
    @ObservableState
    struct State: Equatable {
        var profile: UserProfile
        var usernameToChange : String = ""
        var cityToChange : String = ""
        var isLoading = false
        var selectedImage: PhotosPickerItem? = nil
        var displayImage: UIImage? = nil
        var isSexPickerPresented = false
        @Presents var alert: AlertState<Never>?
    }
    
    enum Action: BindableAction {
        enum ViewAction: Equatable {
            case onSaveButtonTap
            case imageSelected(PhotosPickerItem?)
            case loadImageContent
            case imageLoaded(UIImage?)
            case sexSelected(UserProfile.Sex)
            case toggleSexPicker(Bool)
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
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onSaveButtonTap:
                    state.isLoading = true
                    return .run { [profile = state.profile] send in
                        await send(.internal(.updateProfileResponse(
                            TaskResult { try await apiClient.updateUserProfile(profile) }
                        )))
                    }
                    
                case let .imageSelected(item):
                    state.selectedImage = item
                    return .send(.view(.loadImageContent))
                    
                case .loadImageContent:
                    guard let selectedImage = state.selectedImage else { return .none }
                    
                    return .run { send in
                        let data = try? await selectedImage.loadTransferable(type: Data.self)
                        let image = data.flatMap { UIImage(data: $0) }
                        await send(.view(.imageLoaded(image)))
                    }
                    
                case let .imageLoaded(image):
                    state.displayImage = image
                    // TODO: 上传图片到服务器并获取URL
                    return .none

                case .toggleSexPicker(let isPresented):
                    state.isSexPickerPresented = isPresented
                    return .none
                    
                case let .sexSelected(sex):
                    state.profile.sex = sex
                    state.isSexPickerPresented = false
                    return .none
                }
                
            case let .internal(internalAction):
                switch internalAction {
                case let .updateProfileResponse(.success(profile)):
                    state.isLoading = false
                    return .send(.delegate(.didUpdateProfile(profile)))
                    
                case let .updateProfileResponse(.failure(error)):
                    state.isLoading = false
                    state.alert = AlertState(title: TextState("更新失败"),
                                          message: TextState(error.localizedDescription))
                    return .none
                }
                
            case .alert:
                return .none
                
            case .delegate:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
