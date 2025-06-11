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
    @ObservableState
    struct State: Equatable {
        public var messages: [Message] = []
        public var chatTitle: String = "AI Teacher"
        public var chatStatus: String = "Online"
        public var chatCover: URL?
        public init() {}
    }
    
    @CasePathable
    enum Action: BindableAction {
        enum ViewAction: Equatable {
            case onAppear
            case onDisappear
        }
        case view(ViewAction)
        case sendDraft(DraftMessage)
        case loadMore(before: Message)
        case messagesLoaded([Message])
        case binding(BindingAction<State>)
    }
    
    
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                // Load initial messages or setup
                return .none
            case .view(.onDisappear):
                // Cleanup if needed
                return .none
            case let .sendDraft(draft):
                // Handle sending a message (append for now)
//                let newMessage = Message(
//                    id: UUID().uuidString,
//                    user: .init(id: "current", name: "You", avatarURL: nil, isCurrentUser: true),
//                    text: draft.text,
//                    date: Date(),
//                    status: .sent,
//                    type: .text
//                )
//                state.messages.append(newMessage)
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
