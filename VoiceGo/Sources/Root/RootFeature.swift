//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture
import GRDB
import SharingGRDB


@Reducer
struct RootFeature {

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.defaultDatabase) var database
    
    
    @ObservableState
    struct State : Equatable {
        var profile: UserProfile? = nil
        var currentTab = Tab.studytools
        var tearchListState = AITeacherListFeature.State()
        var studytoolListState = StudyToolsFeature.State()
        var conversationSceneListState = ConversationSceneListFeature.State()
        var profileState = ProfileFeature.State()
        var notifications = NotificationsFeature.State()
        @Presents var alert: AlertState<Never>?
        
        public init(profile: UserProfile? = nil, currentTab: Tab = .studytools) {
            @Dependency(\.defaultDatabase) var database
            @Dependency(\.userDefaults) var userDefaultsClient
            @Dependency(\.userInfoRepository) var userInfoRepository
            
            var profileFetched: UserProfile? = profile
            
            do {
                try database.read({ db in
                profileFetched = try UserProfile.find(db, key: profile?.documentId ?? userDefaultsClient.currentUserID)
                })
            }
            catch{
                
            }
            userInfoRepository.currentUser = profileFetched
            self.profile = profileFetched
            self.currentTab = currentTab
            self.tearchListState = AITeacherListFeature.State()
            self.studytoolListState = StudyToolsFeature.State()
            self.profileState = ProfileFeature.State(profile: profileFetched)
            self.notifications = NotificationsFeature.State()
            self.alert = nil
        }
    }
    
    enum Tab: Int, CaseIterable {
        case favourites
        case tearchList
        case studytools
        case conversationSceneList
        case profile
    }
    
    enum Action: BindableAction {
        case onTabChanged(Tab)
        case addNotifications(NotificationItem)
        
        case tearchList(AITeacherListFeature.Action)
        case studytoolList(StudyToolsFeature.Action)
        case conversationSceneList(ConversationSceneListFeature.Action)
        case profile(ProfileFeature.Action)
        case notifications(NotificationsFeature.Action)
                
        enum Delegate: Equatable {
            case didLogout
        }
        case binding(BindingAction<State>)
        case delegate(Delegate)
        
        case alert(PresentationAction<Never>)
        
        enum InternalAction: Equatable {
            case updateProfileResponse(TaskResult<UserProfile>)
        }
        case `internal`(InternalAction)
        
        case task
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.tearchListState, action: /Action.tearchList) {
            AITeacherListFeature()
        }
        Scope(state: \.studytoolListState, action: /Action.studytoolList) {
            StudyToolsFeature()
        }
        Scope(state: \.conversationSceneListState, action: /Action.conversationSceneList) {
            ConversationSceneListFeature()
        }
        Scope(state: \.profileState, action: /Action.profile) {
            ProfileFeature()
        }
        Scope(state: \.notifications, action: /Action.notifications) {
                    NotificationsFeature()
                }
        Reduce<State, Action> { state, action in
            switch action {
            case .tearchList:
                return .none
            case .studytoolList:
                return .none
            case .onTabChanged(let tab):
                state.currentTab = tab
                return .none
            case .conversationSceneList:
                return .none
            case .profile(.delegate(.didLogout)):
                return .send(.delegate(.didLogout))
            case .profile:
                return .none
            case let .addNotifications(notification):
                            state.notifications.items.append(notification)
                            return .none
            case .notifications(.delegate(.didAccountNotificationTapped)):
                state.currentTab = .profile
                            return .none
            case .binding:
                return .none
            case .notifications(_):
                return .none
            case .notifications(.internal(_)):
                return .none
            case .notifications(.alert(_)):
                return .none
            case .delegate(_):
                return .none
            case .task:
                return .run { send in
                    await send(.internal(.updateProfileResponse(
                        TaskResult { try await apiClient.fetchUserProfile() }
                    )))
                }
            case let .internal(internalAction):
                switch internalAction {
                case let .updateProfileResponse(.success(profile)):
                    state.profile = profile
                    Task{
                        do {
                            try await database.write { db in
                                var profile = profile
                                if var studySetting = profile.study_setting {
                                    try studySetting.upsert(db)
                                    profile.studySettingId = studySetting.id
                                }
                                try profile.upsert(db)
                            }
                        } catch {
                            Log.error("Failed to save user to database: \(error)")
                        }
                    }
                    return .none
                    
                case let .updateProfileResponse(.failure(error)):
                    state.alert = AlertState(title: TextState("更新失败"),
                                          message: TextState(error.localizedDescription))
                    return .none
                }
            case .alert(_):
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
