//
//  StudyToolCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolCell: View {
    let store: StoreOf<StudyToolDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                VStack(alignment: .leading) {
                    Text(viewStore.studyTool.title).font(.system(.title, design: .rounded))
         
                        Text("\(viewStore.studyTool.description)").font(.system(.body, design: .rounded))

                }
                .padding(10)

                Spacer()
                
                AsyncImage(
                    url: URL(string: viewStore.studyTool.imageUrl)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                } placeholder: {
                    ProgressView()
                        .frame(height: 100)
                }
                
            }
            .padding(20)
            
        }
    }
}

struct StudyToolCell_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolCell(
            store: Store(
                initialState: StudyToolDomain.State(
                    studyToolUsedID: "xxdfsdfas",
                    studyTool: .sample[0], card: QACard(id:0  ,isExample: true, originText:"apply", actionText: "翻译", suggestions: ["应用"])
                ),
                reducer: StudyToolDomain.init
            )
        )
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
