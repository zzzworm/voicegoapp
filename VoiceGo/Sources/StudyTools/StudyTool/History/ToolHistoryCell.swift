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
    @State var store: StoreOf<ToolHistoryDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .shadow(radius: 2)
                VStack{
                    HStack {
                        VStack(alignment: .leading) {
                            HStack{
                                Text(viewStore.history.question).font(.system(.title, design: .rounded))
                                VoiceAnimatedButton(animating: $store.isSpeaking) {
                                    if(viewStore.isSpeaking){
                                        viewStore.send(.stopSpeak)
                                    }
                                    else{
                                        viewStore.send(.speakAnswer(viewStore.history.question))
                                    }
                                }
                            }
                            Divider()
                            Markdown("\(viewStore.history.answer)")
                                .textSelection(.enabled)
                                .font(.system(.body, design: .rounded))
                            
                        }
                        .padding(10)
                        
                    }
                    .padding(5)
                    Divider()
                    HStack{
                        
                        VoiceAnimatedButton( animating: $store.isSpeaking) {
                            if(viewStore.isSpeaking){
                                viewStore.send(.stopSpeak)
                            }
                            else{
                                viewStore.send(.speakAnswer(viewStore.history.answer))
                            }
                        }
                        .frame(width:26)
                        
                        Button {
                            viewStore.send(.copyAnswer(viewStore.history.answer))
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(HighlightFillButtonStyle())
                        .frame(width:26)
                        
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
                initialState: ToolHistoryDomain.State(
                    id: UUID(),
                    history: ToolHistory.sample[0],
                    isSpeaking: false
                ),
                reducer: ToolHistoryDomain.init
            )
            
        )
    }
}
