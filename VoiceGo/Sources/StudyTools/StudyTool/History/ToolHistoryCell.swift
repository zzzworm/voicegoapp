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
                    VStack{
                        HStack {
                            VStack(alignment: .leading) {
                                HStack{
                                    Text(viewStore.history.query).font(.system(.body, design: .rounded))
                                        .padding(.trailing, 20)
                                    Spacer()
                                }
                                .overlay(
                                    
                                    VoiceAnimatedButton(animating: $store.isSpeakingQuery) {
                                        if(viewStore.isSpeaking){
                                            viewStore.send(.stopSpeak)
                                        }
                                        else{
                                            viewStore.send(.speakAnswer(viewStore.history.query))
                                        }
                                    }.frame(width:20)
                                    
                                    ,alignment: .topTrailing
                                )
                                
                                
                                Divider()
                                Markdown("\(viewStore.history.answer)")
                                    .markdownTheme(.fancy)
                                    .padding(.trailing, 10)
                                    .textSelection(.enabled)
                                    .font(.system(.body, design: .rounded))
                                
                            }
                            .padding(10)
                            
                        }
                        .padding(5)
                        Divider()
                        HStack{
                            VoiceAnimatedButton( animating: $store.isSpeakingAnswer) {
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
                initialState: ToolHistoryFeature.State(
                    history: ToolConversation.sample[0]
                ),
                reducer: ToolHistoryFeature.init
            )
            
        )
    }
}
