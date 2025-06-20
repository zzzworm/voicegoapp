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


final class AITeacherReactionDelegate: NSObject, ReactionDelegate {
    private let store: StoreOf<AIConversationsPageFeature>

    init(store: StoreOf<AIConversationsPageFeature>) {
        self.store = store
    }

    @MainActor
    func didReact(to message: Message, reaction: DraftReaction) {
        store.send(.didReact(to: message, reaction: reaction))
    }

    nonisolated func canReact(to message: Message) -> Bool {
        return !message.user.isCurrentUser || !message.reactions.isEmpty
    }

    nonisolated func reactions(for message: Message) -> [ReactionType]? {
        if message.user.isCurrentUser {
            return nil
        }
        else{
            return [
                .emoji("👍"),
                .emoji("❤️"),
                .emoji("😢")
            ]
        }
    }

    nonisolated func allowEmojiSearch(for message: Message) -> Bool {
        return false
    }

    @MainActor
    func shouldShowOverview(for message: Message) -> Bool {
        store.withState { state in
            if let index = state.messages.firstIndex(where: { $0.id == message.id }) {
                let reactions = state.messages[index].reactions
                return !reactions.isEmpty
            }
            return false
        }
    }
}
