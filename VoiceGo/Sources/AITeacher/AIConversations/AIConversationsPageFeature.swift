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
import SwiftUICore

enum MessageAction: MessageMenuAction {
    case copy, reply, edit, delete

    func title() -> String {
        switch self {
        case .copy:
            "Copy"
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        case .delete:
            "Delete"
        }
    }

    func icon() -> Image {
        switch self {
        case .copy:
            Image(systemName: "doc.on.doc")
        case .reply:
            Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            Image(systemName: "square.and.pencil")
        case .delete:
            Image(systemName: "trash")
        }
    }

    // Optional
    // Implement this method to conditionally include menu actions on a per message basis
    // The default behavior is to include all menu action items
    static func menuItems(for message: ExyteChat.Message) -> [MessageAction] {
        if message.user.isCurrentUser {
            return [.edit, .delete]
        } else {
            return [.copy, .reply]
        }
    }
}

extension ExyteChat.Message: Equatable {
    public static func == (lhs: ExyteChat.Message, rhs: ExyteChat.Message) -> Bool {
        return lhs.id == rhs.id &&
            lhs.user == rhs.user &&
            lhs.status == rhs.status &&
            lhs.createdAt == rhs.createdAt &&
            lhs.text == rhs.text &&
            lhs.attachments == rhs.attachments &&
            lhs.reactions == rhs.reactions &&
            lhs.associations == rhs.associations &&
            lhs.giphyMediaId == rhs.giphyMediaId &&
            lhs.recording == rhs.recording &&
            lhs.replyMessage == rhs.replyMessage
    }
}

extension ExyteChat.DraftMessage: Equatable {
    public static func == (lhs: ExyteChat.DraftMessage, rhs: ExyteChat.DraftMessage) -> Bool {
        return lhs.text == rhs.text &&
            lhs.medias == rhs.medias &&
            lhs.giphyMedia == rhs.giphyMedia &&
            lhs.recording == rhs.recording &&
            lhs.replyMessage == rhs.replyMessage &&
            lhs.createdAt == rhs.createdAt
    }
}

@Reducer
struct AIConversationsPageFeature {
    @Dependency(\.userInfoRepository) var userInfoRepository
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.clipboardClient) var clipboardClient

    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.AlertAction>?
        public var messages: [ExyteChat.Message] = []
        public var chatTitle: String {
            aiTeacher.name
        }
        public var chatCover: URL? {
            URL(string: aiTeacher.coverUrl)
        }
        var aiTeacher: AITeacher
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
        var pendingMessage: ExyteChat.Message?
        var pendingDrfat: DraftMessage?
        var isSending: Bool {
            nil != pendingMessage
        }
        var paginationState: Pagination?
        var isLoadMore = false
        var isScrolling = false
        var reactionState = AITeacherChatReactionFeature.State()
        var inputBarState = BottomInputBarFeature.State()

        public init(aiTeacher: AITeacher) {
            self.aiTeacher = aiTeacher
        }
    }

    @CasePathable
    enum Action: BindableAction {
        case view(ViewAction)
        case reaction(AITeacherChatReactionFeature.Action)
        case inputBar(BottomInputBarFeature.Action)
        enum ViewAction: Equatable {
            case onAppear
            case onDisappear
        }
        case fetchConversationList(page: Int, pageSize: Int)
        case fetchConversationListResponse(TaskResult<StrapiResponse<[AITeacherConversation]>>)
        case sendDraft(DraftMessage)
        case stopMessageing(ExyteChat.Message, DraftMessage)
        case deleteMessage(ExyteChat.Message)
        case sendDraftFailed(ExyteChat.Message, DraftMessage)
        case loadMore(before: ExyteChat.Message)
        case messagesLoaded([ExyteChat.Message])
        case tapAssociation(ExyteChat.Message, ExyteChat.Association)
        case copyMessage(ExyteChat.Message)
        case useAgeReachLimit
        enum AlertAction: Equatable {
            case confirmUpgradePlan
        }
        case alert(PresentationAction<AlertAction>)
        case binding(BindingAction<State>)
    }

    private func createInitialMessages(from aiTeacher: AITeacher) -> [ExyteChat.Message] {
        let chatUser = aiTeacher.toChatUser()
        guard let card = aiTeacher.card, let message = card.openingLetter else { return [] }

        var associations: [Association] = []

        if let simpleReplay = card.simpleReplay {
            let association = Association(
                id: uuid().uuidString,
                type: .suggestion("简单: \(simpleReplay)")
            )
            associations.append(association)
        }

        if let formalReplay = card.formalReplay {

            let association = Association(
                id: uuid().uuidString,
                type: .suggestion("地道: \(formalReplay)")
            )
            associations.append(association)
        }

        return [
            ExyteChat.Message(
                id: uuid().uuidString,
                user: chatUser,
                status: .sent,
                createdAt: Date(),
                text: message,
                associations: associations
            )
        ]
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.reactionState, action: \.reaction) {
            AITeacherChatReactionFeature()
        }
        Scope(state: \.inputBarState, action: /Action.inputBar) {
            BottomInputBarFeature()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetchConversationList(let page, let pageSize):
                if state.dataLoadingStatus == .loading {
                    return .none
                }
                if !state.isLoadMore {
                    state.dataLoadingStatus = .loading
                }
                let aiTeacherUsedID = state.aiTeacher.documentId
                return .run { send in
                    do {
                        let result =  try await apiClient.getAITeacherConversationList(aiTeacherUsedID, page, pageSize)
                        return await send(.fetchConversationListResponse(.success(result)))
                    } catch {
                        return await send(.fetchConversationListResponse(.failure(error)))
                    }

                }
            case .fetchConversationListResponse(.success(let conversationListRsp)):
                MainActor.assumeIsolated {
                    let conversationList = conversationListRsp.data
                    state.paginationState = conversationListRsp.meta?.pagination
                    state.isLoadMore = false
                    state.dataLoadingStatus = .success
                    if let page = state.paginationState?.page, page == 1 {
                        let sortedConversations = conversationList.reversed()
                        var toAddedMessages: [ExyteChat.Message] = []
                        if let latestConversation = sortedConversations.last {
                            toAddedMessages = sortedConversations.dropLast().map { conversation in
                                return conversation.toChatMessage()
                             }.flatMap { $0 }
                            toAddedMessages.append(contentsOf: latestConversation.toChatLatestMessage())
                        }
                        state.messages = toAddedMessages

                    } else {
                        let addMessages = conversationList.reversed().map { conversation in
                            return conversation.toChatMessage()
                        }.flatMap { $0 }
                        // 新到的下一页内容往前插入
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
            case .tapAssociation(let message, let association):
                switch association.type {
                case .suggestion(let suggestReply):
                    // Handle association tap
                    let reply: String = String(suggestReply.split(separator: ":").last ?? "")
                    state.inputBarState.text = reply
                }
                return .none

            case let .sendDraft(draft):
                // Handle sending a message (append for now)
                let chatUser = userInfoRepository.currentUser!.toChatUser()
                let newMessage = ExyteChat.Message(
                    id: draft.id ?? uuid().uuidString,
                    user: chatUser,
                    status: .sending,
                    createdAt: Date(),
                    text: draft.text,
                    giphyMediaId: draft.giphyMedia?.id,
                    recording: draft.recording,
                    replyMessage: draft.replyMessage
                )
                state.messages.append(newMessage)
                state.pendingMessage = newMessage
                var aiTeacher = state.aiTeacher
                return .run {send in
                    do {
                        let response = try await apiClient.createAITeacherConversation(aiTeacher, draft.text)
                        let answerMsg = await response.data.toAnswerMessage()
                        return await send(.messagesLoaded([answerMsg]))
                    } catch let error as StrapiSwiftError {
                        switch error {
                        case .badResponse(let statusCode, let errorDetails):
                            if let errorName = errorDetails?.name, errorName == "FreeTrialLimitExceededError" {
                                return await send(.useAgeReachLimit)
                            }
                        default:
                            return await send(.sendDraftFailed(newMessage, draft))
                        }
                    }
                }
            case .stopMessageing(let message, let draft):
                return .send(.sendDraftFailed(message, draft))
            case .useAgeReachLimit:
                state.alert = AlertState(
                    title: TextState("Upgrade Plan"),
                    message: TextState("You have reached the usage limit for this AI teacher. Please upgrade your plan to continue."),
                    buttons: [
                        ButtonState(role: .destructive, action: .confirmUpgradePlan) {
                            TextState(String(localized: "升级", comment: "Useage Limited Alert"))
                        }
                    ]
                )
                return .none
            case let .deleteMessage(message):
                state.messages.removeAll { $0.id == message.id }
                return .none
            case let .sendDraftFailed(draftMessage, draft):

                if let index = state.messages.firstIndex(where: { $0.id == draftMessage.id }) {
                    var message = state.messages[index]
                    message.status = .error(draft)
                    state.messages[index] = message
                } else {
                    /// If the draft message is not found, we can log or handle it accordingly
                }
                state.pendingMessage = nil
                return .none
            case let .loadMore(before):
                let createdAt = before.createdAt
                let pageSize = 10
                var aiTeacher = state.aiTeacher
                return .run { send in
                    do {
                        let result =  try await apiClient.loadMoreAITeacherConversationList(aiTeacher.documentId, createdAt, pageSize)
                        return await send(.fetchConversationListResponse(.success(result)))
                    } catch {
                        return await send(.fetchConversationListResponse(.failure(error)))
                    }
                }
            case let .messagesLoaded(messages):
                if var latestHasAssociationsIndex = state.messages.lastIndex(where: { $0.associations.isEmpty == false }) {
                    var latestMessage = state.messages[latestHasAssociationsIndex]
                    latestMessage.associations = []
                    state.messages[latestHasAssociationsIndex] = latestMessage
                }
                if var latestMessage = state.messages.last {
                    latestMessage.status = .read
                    state.messages[state.messages.count - 1] = latestMessage
                }
                state.messages.append(contentsOf: messages)
                state.pendingMessage = nil
                return .none
            case .copyMessage(let message):
                // Handle copy action
                clipboardClient.copyValue(message.text)
                return .none
            case .binding:
                return .none
            case .reaction:
                return .none
            case .inputBar(let action):
                switch action {
                case .binding:
                    break
                case .textChanged:
                    break
                case .speechRecognitionInput:
                    break
                case .submitText(let reply):
                    if reply.isEmpty {
                        return .none
                    }
                    let draft = DraftMessage(
                        text: reply,
                        medias: [],
                        giphyMedia: nil,
                        recording: nil,
                        replyMessage: nil,
                        createdAt: Date()
                    )
                    return.send(.sendDraft(draft))

                case .toggleSpeechMode:
                    break
                }
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
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
