//
//  ToolHeaderCard.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//

import SwiftUI
import MarkdownUI


struct QIntroduceListCard : Equatable{
    var caption : String = ""
    var suggestions: [String] = []
}

struct ToolIntroduceListCardView: View {
    let card: QIntroduceListCard
    let cornerRadius: CGFloat = 15.0
    var body: some View{
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.white)
                .shadow(radius: 5)
            
            VStack {
                HStack(){
                    Text(card.caption)
                    Spacer()
                }
                VStack {
                    ForEach(card.suggestions){ suggestion in
                        GroundedCaptionItemView(caption:suggestion)
                    }
                }
            }
            .padding(10)
        }
        .frame( height: 250)
        
    }
    
}


#Preview {
    ToolIntroduceListCardView(card: QIntroduceListCard(caption: "翻译", suggestions: ["hi"]))
}
