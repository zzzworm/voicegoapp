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
    let store: StoreOf<AIConversationsPageFeature>
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    private let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)

#if DEBUG
    @ObserveInjection var forceRedraw
#endif

    var body: some View {
        content
            .enableInjection()
    }

    @ViewBuilder private var content: some View {
            ChatView(messages: store.state.messages, chatType: .conversation) { draft in
                store.send(.sendDraft(draft))
            }
            .enableLoadMore(pageSize: 3) { message in
                    store.send(.loadMore(before: message))
                
            }
            .messageUseMarkdown(true)
            .setRecorderSettings(recorderSettings)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button { presentationMode.wrappedValue.dismiss() } label: {
//                        Image("backArrow", bundle: .current)
//                            .renderingMode(.template)
//                            .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    }
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    HStack {
//                        if let url = store.state.chatCover {
//                            CachedAsyncImage(url: url, urlCache: .shared) { phase in
//                                switch phase {
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                default:
//                                    Rectangle().fill(Color(hex: "AFB3B8"))
//                                }
//                            }
//                            .frame(width: 35, height: 35)
//                            .clipShape(Circle())
//                        }
//                        VStack(alignment: .leading, spacing: 0) {
//                            Text(store.state.chatTitle)
//                                .fontWeight(.semibold)
//                                .font(.headline)
//                                .foregroundStyle(colorScheme == .dark ? .white : .black)
//                            Text(store.state.chatStatus)
//                                .font(.footnote)
//                                .foregroundColor(Color(hex: "AFB3B8"))
//                        }
//                        Spacer()
//                    }
//                    .padding(.leading, 10)
//                }
//            }
            .onAppear { store.send(.view(.onAppear)) }
            .onDisappear { store.send(.view(.onDisappear)) }
        }
}


#Preview {
        AIConversationsPageView(
            store: Store(
                initialState: AIConversationsPageFeature.State(),
                reducer: {AIConversationsPageFeature()}
            )
        )
}
