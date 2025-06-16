//
//  AIConversationsPageView.swift
//  VoiceGo
//
//  Created by Cascade AI on 2025-06-11.
//

import SwiftUI
import ComposableArchitecture
import ExyteChat
#if DEBUG
import InjectionNext
#endif

struct AIConversationsPageView: View {
    @Bindable var store: StoreOf<AIConversationsPageFeature>
    private let reactionDelegate: AITeacherReactionDelegate

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.chatTheme) private var theme

    private let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)

    @ViewBuilder
    private func messageInputView(
        textBinding: Binding<String>,
        inputViewStyle: InputViewStyle,
        inputViewActionClosure: @escaping (InputViewAction) -> Void
    ) -> some View {
        Group {
            switch inputViewStyle {
            case .message: // input view on chat screen
                VStack {
                    HStack {
//                        Button { inputViewActionClosure(.photo) }
//                        label: {
//                            theme.images.inputView.attachCamera
//                                .frame(width: 40, height: 40)
//                                .background {
//                                    Circle().fill(theme.colors.sendButtonBackground)
//                                }
//                        }

                        BottomInputBarBarView(store: store.scope(state: \.inputBarState, action: \.inputBar))
                        if store.state.isSending {
                            Button {
                                if let pendingMessage = store.state.pendingMessage,
                                   let pendingDrfat = store.state.pendingDrfat {
                                    // Stop sending the message
                                    store.send(.stopMessageing(pendingMessage, pendingDrfat))
                                }
                            }
                            label: {
                                Image(systemName: "stop.fill")
                                    .frame(width: 40, height: 40)
                                    .background {
                                        Circle().fill(theme.colors.sendButtonBackground)
                                    }
                            }
                        } else {
                            Button {
                                inputViewActionClosure(.send)
                            }
                            label: {
                                theme.images.inputView.arrowSend
                                    .frame(width: 40, height: 40)
                                    .background {
                                        Circle().fill(theme.colors.sendButtonBackground)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    Text("AI生成内容，仅供参考").padding(.bottom, 5)
                }

            case .signature: // input view on photo selection screen
                VStack {
                    HStack {
                        TextField("Compose a signature for photo", text: textBinding)
                            .background(Color.white)

                        Button {
                            inputViewActionClosure(.send)
                        }
                        label: {
                            theme.images.inputView.arrowSend
                                .frame(width: 40, height: 40)
                                .background {
                                    Circle().fill(theme.colors.sendButtonBackground)
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
    }

    init(store: StoreOf<AIConversationsPageFeature>) {
        self.store = store
        self.reactionDelegate = AITeacherReactionDelegate(
            store: store.scope(state: \.reactionState, action: \.reaction)
        )
    }

#if DEBUG
    @ObserveInjection var forceRedraw
#endif

    @ViewBuilder
    private var navigationBarLeadingContent: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            if let url = store.state.chatCover {
                CachedAsyncImage(url: url, urlCache: .shared) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle().fill(Color(hex: "AFB3B8"))
                    }
                }
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(store.state.chatTitle)
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            Spacer()
        }
        .padding(.leading, 10)
    }

    var body: some View {
        content
            .enableInjection()
    }

    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            var chatView = ChatView(
                messages: store.state.messages,
                chatType: .conversation,
                didSendMessage: { draft in
                    store.send(.sendDraft(draft))
                },
                reactionDelegate: reactionDelegate,
                inputViewBuilder: { textBinding, _, _, inputViewStyle, inputViewActionClosure, _ in
                    messageInputView(
                        textBinding: textBinding,
                        inputViewStyle: inputViewStyle,
                        inputViewActionClosure: inputViewActionClosure
                    )
                    .onChange(of: store.inputBarState.text) { _, newValue in
                        if textBinding.wrappedValue != newValue {
                            textBinding.wrappedValue = newValue
                        }
                    }
                    .onChange(of: textBinding.wrappedValue) { _, newValue in
                        if store.inputBarState.text != newValue {
                            store.send(.set(\.inputBarState.text, newValue))
                        }
                    }
                },
                messageMenuAction: { (action: MessageAction, defaultActionClosure, message) in // <-- here: specify the name of your `MessageMenuAction` enum
                                    switch action {
                                    case .reply:
                                        defaultActionClosure(message, .reply)
                                    case .edit:
                                        defaultActionClosure(message, .edit { editedText in
                                            // update this message's text on your BE
                                            let draft = DraftMessage(
                                                text: editedText,
                                                medias: [],
                                                giphyMedia: nil,
                                                recording: nil,
                                                replyMessage: nil,
                                                createdAt: Date()
                                            )
                                            store.send(.sendDraft(draft))
                                        })
                                    case .copy:
                                        store.send(.copyMessage(message))
                                    case .delete:
                                        store.send(.deleteMessage(message))
                                    }
                }

            )

            if let pageCount = store.state.paginationState?.pageCount, pageCount > 1 {
                chatView.enableLoadMore(pageSize: 3) { message in
                    store.send(.loadMore(before: message))
                }
            }

            chatView
                .messageUseMarkdown(true)
                .setRecorderSettings(recorderSettings)
                .tapAssociationClosure({ message, association in

                    store.send(.tapAssociation(message, association))

                })
                .alert($store.scope(state: \.alert, action: \.alert))
                .disabled(store.isLoading)
                .overlay {
                    if store.isLoading {
                        ProgressView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        navigationBarLeadingContent
                    }
                }
                .onAppear { store.send(.view(.onAppear)) }
                .onDisappear { store.send(.view(.onDisappear)) }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .task {
                    store.send(.fetchConversationList(page: 1, pageSize: 20))
                }
        }
    }
}

#Preview {
    AIConversationsPageView(
        store: Store(
            initialState: AIConversationsPageFeature.State(aiTeacher: AITeacher.sample[0]),
            reducer: { AIConversationsPageFeature() }
        )
    )
}
