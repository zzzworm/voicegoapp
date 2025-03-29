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
    let store: StoreOf<ToolHistoryDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .shadow(radius: 10)
                VStack{
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewStore.history.question).font(.system(.title, design: .rounded))
                            Divider()
                            Markdown("\(viewStore.history.answer)").font(.system(.body, design: .rounded))
                            
                        }
                        .padding(10)
                        
                    }
                    .padding(5)
                    Divider()
                    HStack{
                        Button {
                            
                            viewStore.send(.speakAnswer(viewStore.history.answer))
                        } label: {
                            Image(systemName: "speaker.3")
                        }.buttonStyle(HighlightFillButtonStyle())
                        Button {
                            viewStore.send(.copyAnswer(viewStore.history.answer))
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }.buttonStyle(HighlightFillButtonStyle())
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
                    history: ToolHistory.sample[0]
                ),
                reducer: ToolHistoryDomain.init
            )
        )
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
