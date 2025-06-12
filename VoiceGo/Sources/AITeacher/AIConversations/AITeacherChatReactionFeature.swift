//
//  AITeacherChatReaction.swift
//  VoiceGo
//
//  Created by admin on 2025/6/12.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import Foundation
import ComposableArchitecture
import ExyteChat

@Reducer
struct AITeacherChatReactionFeature {
    @Dependency(\.userInfoRepository) var userInfoRepository
    @Dependency(\.uuid) var uuid
    
    @ObservableState
    struct State: Equatable {
        var messageReactions: [String: [Reaction]] = [:]
    }
    
    enum Action {
        case didReact(to: Message, reaction: DraftReaction)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .didReact(message, draftReaction):
                guard let user = userInfoRepository.currentUser?.toChatUser() else {
                    return .none
                }
                
                let newReaction = Reaction(
                    id: uuid().uuidString,
                    user: user,
                    createdAt: Date(),
                    type: draftReaction.type
                )
                
                if state.messageReactions[message.id] == nil {
                    state.messageReactions[message.id] = []
                }
                
                if let index = state.messageReactions[message.id]?.firstIndex(where: { $0.user.id == user.id && $0.type == newReaction.type }) {
                    state.messageReactions[message.id]?.remove(at: index)
                } else {
                    state.messageReactions[message.id]?.append(newReaction)
                }
                
                return .none
            }
        }
    }
}

final class AITeacherReactionDelegate: NSObject, ReactionDelegate {
    private let store: StoreOf<AITeacherChatReactionFeature>
    
    init(store: StoreOf<AITeacherChatReactionFeature>) {
        self.store = store
    }

    @MainActor
    func didReact(to message: Message, reaction: DraftReaction) {
        store.send(.didReact(to: message, reaction: reaction))
    }

    nonisolated func canReact(to message: Message) -> Bool {
        return !message.user.isCurrentUser
    }

    nonisolated func reactions(for message: Message) -> [ReactionType]? {
        return [
            .emoji("👍"),
            .emoji("❤️"),
            .emoji("😢")
        ]
    }

    nonisolated func allowEmojiSearch(for message: Message) -> Bool {
        return true
    }

    @MainActor
    func shouldShowOverview(for message: Message) -> Bool {
        store.withState { state in
            !(state.messageReactions[message.id]?.isEmpty ?? true)
        }
    }
}
