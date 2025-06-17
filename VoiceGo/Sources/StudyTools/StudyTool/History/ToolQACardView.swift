//
//  ToolHeaderCard.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//

import SwiftUI
import MarkdownUI

struct ToolQACardView: View {
    let card: QACard
    let cornerRadius: CGFloat = 15.0
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.white)
                .shadow(radius: 2)
            VStack {
                HStack {
                    Spacer()
                    Text("示例")
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background {
                            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: cornerRadius, bottomTrailing: 0, topTrailing: cornerRadius))
                                .fill(.blue)
                                .shadow(radius: 2)
                        }

                }
                Spacer()
            }
            VStack(alignment: .leading) {
                GroundedCaptionView(caption: card.originCaption)
                Text(card.originText).padding(EdgeInsets(top: 5, leading: 5, bottom: 10, trailing: 5))
                GroundedCaptionView(caption: card.actionText)
                if let answer = card.suggestions.first {
                    if let attributedString = try? AttributedString(markdown: answer,
                                                                    options: .init(interpretedSyntax: .
                                                                                   inlineOnlyPreservingWhitespace,
                                                                                   failurePolicy: .returnPartiallyParsedIfPossible)) {
                        Text(attributedString)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 10, trailing: 5))
                    } else {
                        Text(answer).padding(EdgeInsets(top: 5, leading: 5, bottom: 10, trailing: 5))
                    }
//                    Markdown(answer)
                }
                Spacer()
            }
            .padding(10)
        }
    }

}

#Preview {
    ToolQACardView(card: QACard( id: 0, isExample: true, originText: "apply", actionText: "翻译", suggestions: ["应用"]))
}
