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

enum MessageAction: MessageMenuAction {
    case copy,reply, edit

    func title() -> String {
        switch self {
        case .copy:
            "Copy"
        case .reply:
            "Reply"
        case .edit:
            "Edit"
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
        }
    }
    
    // Optional
    // Implement this method to conditionally include menu actions on a per message basis
    // The default behavior is to include all menu action items
    static func menuItems(for message: ExyteChat.Message) -> [MessageAction] {
        if message.user.isCurrentUser  {
            return [.edit]
        } else {
            return [.copy,.reply]
        }
    }
}


struct AIConversationsPageView: View {
    let store: StoreOf<AIConversationsPageFeature>
    private let reactionDelegate: AITeacherReactionDelegate
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    private let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)
    
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
        var chatView = ChatView(
            messages: store.state.messages,
            chatType: .conversation,
            didSendMessage: { draft in
                store.send(.sendDraft(draft))
            },
            reactionDelegate: reactionDelegate,
            messageMenuAction: { (action: MessageAction, defaultActionClosure, message) in // <-- here: specify the name of your `MessageMenuAction` enum
//                switch action {
//                case .reply:
//                    defaultActionClosure(message, .reply)
//                case .edit:
//                    defaultActionClosure(message, .edit { editedText in
//                        // update this message's text on your BE
//                        print(editedText)
//                    })
//                }
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


#Preview {
    AIConversationsPageView(
        store: Store(
            initialState: AIConversationsPageFeature.State(aiTeacher: AITeacher.sample[0]),
            reducer: { AIConversationsPageFeature() }
        )
    )
}
