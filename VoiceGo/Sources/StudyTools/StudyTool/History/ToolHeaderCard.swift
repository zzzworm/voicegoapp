//
//  ToolHeaderCard.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//

import SwiftUI
import MarkdownUI

struct Card{
    var isExample : Bool = true
    var originText : String = ""
    var actionText : String = ""
    var answer: String = ""
}

struct ToolHeaderCardView: View {
    let card: Card
    
    var body: some View{
        ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 25)
                .fill(.white)
                .shadow(radius: 10)
            VStack{
                HStack{
                    Spacer()
                    Text("New")
                }.padding(20)
                Spacer()
            }
            VStack {
                
                        Text("原文").padding(15)
                        Text(card.originText)
                        Text(card.actionText)
                            .font(.body)
                            .foregroundStyle(.black)

                        Text(card.answer)
                            .font(.title)
                            .foregroundStyle(.secondary)
                Spacer()
                    }
                    .padding(10)
                }
                .frame( height: 250)
        
    }
    
}


#Preview {
    ToolHeaderCardView(card: Card(isExample: true, originText:"apply", actionText: "翻译", answer: "应用"))
}
