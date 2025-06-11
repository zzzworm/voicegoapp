//
//  AIConversationsPageFeature.swift
//  VoiceGo
//
//  Created by Cascade AI on 2025-06-11.
//

import Foundation
import ComposableArchitecture
import ExyteChat

@Reducer
struct AIConversationsPageFeature {
    @Dependency(\.userInfoRepository) var userInfoRepository
    @ObservableState
    struct State: Equatable {
        public var messages: [ExyteChat.Message] = []
        public var chatTitle: String{
            aiTeacher.name
        }
        public var chatStatus: String = "Online"
        public var chatCover: URL?{
            URL(string: aiTeacher.coverUrl)
        }
        var aiTeacher : AITeacher
        public init(aiTeacher: AITeacher) {
            self.aiTeacher = aiTeacher
        }
    }
    
    @CasePathable
    enum Action: BindableAction {
        enum ViewAction: Equatable {
            case onAppear
            case onDisappear
        }
        case view(ViewAction)
        case sendDraft(DraftMessage)
        case loadMore(before: ExyteChat.Message)
        case messagesLoaded([ExyteChat.Message])
        case binding(BindingAction<State>)
    }
    
    
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                // Load initial messages or setup
                if state.messages.isEmpty {
                    // Simulate loading initial messages
                    let chatUser = state.aiTeacher.toChatUser()
                    var message = ""
                    if let card = state.aiTeacher.card {
                        message = card.openingLetter ?? ""
                    }
                    let initialMessages = [
                        ExyteChat.Message(
                            id: UUID().uuidString,
                            user: chatUser,
                            status: .sent,
                            createdAt: Date(),
                            text: message
                        )
                    ]
                    state.messages.append(contentsOf: initialMessages)
                }
                return .none
            case .view(.onDisappear):
                // Cleanup if needed
                return .none
            case let .sendDraft(draft):
                // Handle sending a message (append for now)
                let chatUser = userInfoRepository.currentUser!.toChatUser()
                let newMessage = ExyteChat.Message(
                    id: UUID().uuidString,
                    user: chatUser,
                    status: .sent,
                    createdAt: Date(),
                    text: draft.text
                )
                state.messages.append(newMessage)
                return .none
            case let .loadMore(before):
                // Simulate loading more (prepend dummy message)
//                let more = Message(
//                    id: UUID().uuidString,
//                    user: .init(id: "ai", name: "AI Teacher", avatarURL: nil, isCurrentUser: false),
//                    text: "Older message...",
//                    date: Date().addingTimeInterval(-3600),
//                    status: .sent,
//                    type: .text
//                )
//                state.messages.insert(more, at: 0)
                return .none
            case let .messagesLoaded(messages):
                state.messages = messages
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
