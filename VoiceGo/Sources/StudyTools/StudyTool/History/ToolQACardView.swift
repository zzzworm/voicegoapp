//
//  ToolHeaderCard.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//

import SwiftUI
import MarkdownUI


struct QACard : Equatable{
    var isExample : Bool = true
    var originCaption : String = "原文"
    var originText : String = ""
    var actionText : String = ""
    var answer: String = ""
}

struct ToolQACardView: View {
    let card: QACard
    let cornerRadius: CGFloat = 15.0
    var body: some View{
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.white)
                .shadow(radius: 2)
            VStack{
                HStack{
                    Spacer()
                    Text("示例")
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background{
                            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 0,bottomLeading: cornerRadius, bottomTrailing: 0, topTrailing: cornerRadius))
                                .fill(.blue)
                                .shadow(radius: 2)
                        }
                    
                }
                Spacer()
            }
            VStack {
                GroundedCaptionView(caption: card.originCaption)
                Text(card.originText).padding(EdgeInsets(top: 5, leading: 5, bottom: 10, trailing: 5))
                GroundedCaptionView(caption:card.actionText)
                Markdown(card.answer)
                Spacer()
            }
            .padding(10)
        }
    }
    
}


#Preview {
    ToolQACardView(card: QACard(isExample: true, originText:"apply", actionText: "翻译", answer: "应用"))
}


