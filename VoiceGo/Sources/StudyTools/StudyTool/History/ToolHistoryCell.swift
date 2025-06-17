//
//  ToolHistoryCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture
import MarkdownUI

struct ToolHistoryCell: View {
    @State var store: StoreOf<ToolHistoryFeature>

    var body: some View {

            WithViewStore(self.store, observe: { $0 }) { viewStore in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .shadow(radius: 2)
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(store.state.history.query).font(.system(.body, design: .rounded))
                                        .padding(.trailing, 20)
                                    Spacer()
                                }
                                .overlay(

                                    VoiceAnimatedButton(animating: $store.isSpeakingQuery) {
                                        if viewStore.isSpeaking {
                                            viewStore.send(.stopSpeak)
                                        } else {
                                            viewStore.send(.speakAnswer(viewStore.history.query))
                                        }
                                    }.frame(width: 20), alignment: .topTrailing
                                )

                                Divider()
                                if let answer = viewStore.history.answer {
                                    if let attributedString = try? AttributedString(markdown: answer.answer,
                                                                                    options: .init(interpretedSyntax: .
                                                                                                   inlineOnlyPreservingWhitespace,
                                                                                                   failurePolicy: .returnPartiallyParsedIfPossible)) {
                                                Text(attributedString)
                                                    .multilineTextAlignment(.leading)
                                            } else {
                                                Markdown(answer.answer)
                                                    .markdownTheme(.fancy)
                                                    .textSelection(.enabled)
                                                    .font(.system(.body, design: .rounded))
                                            }
                                    
                                }
                                else{
                                    Text("生成中...")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.label)
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(10)

                        }
                        .padding(5)
                        Divider()
                        HStack {
                            VoiceAnimatedButton( animating: $store.isSpeakingAnswer) {
                                if viewStore.isSpeaking {
                                    viewStore.send(.stopSpeak)
                                } else {
                                    if let answer = viewStore.history.answer {
                                        viewStore.send(.speakAnswer(answer.answer))
                                    }
                                }
                            }
                            .frame(width: 26)

                            Button {
                                if let answer = viewStore.history.answer {
                                    viewStore.send(.speakAnswer(answer.answer))
                                }
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .buttonStyle(HighlightFillButtonStyle())
                            .frame(width: 26)

                            Spacer()
                        }.padding(10)
                    }
                }
            }
        }

}

struct ToolHistoryCell_Previews: PreviewProvider {
    static var previews: some View {
        ToolHistoryCell(
            store: Store(
                initialState: ToolHistoryFeature.State(
                    history: ToolConversation.sample[0]
                ),
                reducer: ToolHistoryFeature.init
            )

        )
    }
}
