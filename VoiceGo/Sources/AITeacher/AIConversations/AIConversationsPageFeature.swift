//
//  AIConversationsPageFeature.swift
//  VoiceGo
//
//  Created by Cascade AI on 2025-06-11.
//

import Foundation
import ComposableArchitecture
import ExyteChat
import StrapiSwift

@Reducer
struct AIConversationsPageFeature {
    @Dependency(\.userInfoRepository) var userInfoRepository
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        public var messages: [ExyteChat.Message] = []
        public var chatTitle: String{
            aiTeacher.name
        }
        public var chatCover: URL?{
            URL(string: aiTeacher.coverUrl)
        }
        var aiTeacher : AITeacher
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var paginationState : Pagination?
        var isLoadMore = false
        var isScrolling = false
        var reactionState = AITeacherChatReactionFeature.State()

        public init(aiTeacher: AITeacher) {
            self.aiTeacher = aiTeacher
        }
    }
    
    @CasePathable
    enum Action: BindableAction {
        case reaction(AITeacherChatReactionFeature.Action)
        enum ViewAction: Equatable {
            case onAppear
            case onDisappear
        }
        case view(ViewAction)
        case fetchConversationList(page: Int, pageSize: Int)
        case fetchConversationListResponse(TaskResult<StrapiResponse<[AITeacherConversation]>>)
        case sendDraft(DraftMessage)
        case deleteMessage(ExyteChat.Message)
        case sendDraftFailed(ExyteChat.Message,DraftMessage)
        case loadMore(before: ExyteChat.Message)
        case messagesLoaded([ExyteChat.Message])
        case binding(BindingAction<State>)
    }
    
    
    
    private func createInitialMessages(from aiTeacher: AITeacher) -> [ExyteChat.Message] {
        let chatUser = aiTeacher.toChatUser()
        guard let card = aiTeacher.card, let message = card.openingLetter else { return [] }
        
        var suggestions: [String] = []
        
        if let simpleReplay = card.simpleReplay {
            suggestions.append("简单: \(simpleReplay)")
        }
        
        if let formalReplay = card.formalReplay {

            suggestions.append("地道: \(formalReplay)")
        }
        
        return [
            ExyteChat.Message(
                id: uuid().uuidString,
                user: chatUser,
                status: .sent,
                createdAt: Date(),
                text: message,
                suggestions: suggestions
            )
        ]
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.reactionState, action: \.reaction) {
            AITeacherChatReactionFeature()
        }

        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetchConversationList(let page, let pageSize):
                if state.dataLoadingStatus == .loading {
                    return .none
                }
                if !state.isLoadMore{
                    state.dataLoadingStatus = .loading
                }
                let aiTeacherUsedID = state.aiTeacher.documentId
                return .run{ send in
                    do{
                        let result =  try await apiClient.getAITeacherConversationList(aiTeacherUsedID, page, pageSize)
                        return await send(.fetchConversationListResponse(.success(result)))
                    }
                    catch {
                        return await send(.fetchConversationListResponse(.failure(error)))
                    }
                    
                }
            case .fetchConversationListResponse(.success(let conversationListRsp)):
                MainActor.assumeIsolated{
                    let conversationList = conversationListRsp.data
                    state.paginationState = conversationListRsp.meta?.pagination
                    state.isLoadMore = false
                    state.dataLoadingStatus = .success
                    if let page = state.paginationState?.page, page == 1{
                        let sortedConversations = conversationList.reversed()
                        var toAddedMessages: [ExyteChat.Message] = []
                        if let latestConversation = sortedConversations.last{
                            toAddedMessages = sortedConversations.dropLast().map { conversation in
                                return conversation.toChatMessage()
                             }.flatMap { $0 }
                            toAddedMessages.append(contentsOf: latestConversation.toChatLatestMessage())
                        }
                        state.messages = toAddedMessages
                        
                    }
                    else{
                        let addMessages = conversationList.reversed().map { conversation in
                            return conversation.toChatMessage()
                        }.flatMap { $0 }
                        //新到的下一页内容往前插入
                        state.messages.insert(contentsOf: addMessages, at: 0)
                    }
                    if state.messages.isEmpty {
                    let initialMessages = createInitialMessages(from: state.aiTeacher)
                    state.messages.append(contentsOf: initialMessages)
                }
                }
                return .none
            case let .fetchConversationListResponse(.failure(error)):
                state.dataLoadingStatus = .error
                state.isLoadMore = false
                if state.messages.isEmpty {
                    let initialMessages = createInitialMessages(from: state.aiTeacher)
                    state.messages.append(contentsOf: initialMessages)
                }
                return .none
            case .view(.onAppear):
                // Load initial messages or setup
                
                return .none
            case .view(.onDisappear):
                // Cleanup if needed
                return .none
            case let .sendDraft(draft):
                // Handle sending a message (append for now)
                if var latestMessage = state.messages.last {
                    latestMessage.reactions = []
                    state.messages[state.messages.count - 1] = latestMessage
                }
                let chatUser = userInfoRepository.currentUser!.toChatUser()
                let newMessage = ExyteChat.Message(
                    id: draft.id ?? uuid().uuidString,
                    user: chatUser,
                    status: .sending,
                    createdAt: Date(),
                    text: draft.text
                )
                state.messages.append(newMessage)
                var aiTeacher = state.aiTeacher
                return .run {send in
                    do{
                        let response = try await apiClient.createAITeacherConversation(aiTeacher, draft.text)
                        let answerMsg = await response.data.toAnswerMessage()
                        return await send(.messagesLoaded([answerMsg]))
                    }
                    catch{
                        return await send(.sendDraftFailed(newMessage,draft))
                    }
                }
            case let .deleteMessage(message):
                state.messages.removeAll { $0.id == message.id }
                return .none
            case let .sendDraftFailed(draftMessage,draft):
                
                if let index = state.messages.firstIndex(where: { $0.id == draftMessage.id }) {
                    var message = state.messages[index];
                    message.status = .error(draft)
                    state.messages[index] = message
                } else {
                    /// If the draft message is not found, we can log or handle it accordingly
                }
                return .none
            case let .loadMore(before):
                // Simulate loading more (prepend dummy message)
//                let more = Message(
//                    id: uuid().uuidString,
//                    user: .init(id: "ai", name: "AI Teacher", avatarURL: nil, isCurrentUser: false),
//                    text: "Older message...",
//                    date: Date().addingTimeInterval(-3600),
//                    status: .sent,
//                    type: .text
//                )
//                state.messages.insert(more, at: 0)
                return .none
            case let .messagesLoaded(messages):
                state.messages.append(contentsOf: messages)
                return .none
            case .binding(_):
                return .none
            case .reaction(_):
                return .none
            }
        }
        .onChange(of: \.reactionState.messageReactions) { _, newValue in
            Reduce { state, _ in
                for (messageId, reactions) in newValue {
                    if let index = state.messages.firstIndex(where: { $0.id == messageId }) {
                        state.messages[index].reactions = reactions
                    }
                }
                return .none
            }
        }
    }
}
