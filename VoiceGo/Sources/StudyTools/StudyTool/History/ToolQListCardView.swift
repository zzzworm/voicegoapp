//
//  ToolHeaderCard.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//

import SwiftUI
import MarkdownUI

struct ToolQListCardView: View {
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
            VStack {

                GroundedCaptionView(caption: card.originCaption)
                Text(card.originText)
                GroundedCaptionView(caption: card.actionText)

                VStack {
                    ForEach(card.suggestions) { suggestion in
                        GroundedCaptionItemView(caption: suggestion)
                    }
                }
                Spacer()
            }
            .padding(10)
        }
        .frame( height: 250)

    }

}

#Preview {
    ToolQListCardView(card: QACard(id: 0, isExample: true, originText: "apply", actionText: "翻译", suggestions: ["hi"]))
}
