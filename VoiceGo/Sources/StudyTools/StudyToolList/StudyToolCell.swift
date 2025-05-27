//
//  StudyToolCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolCell: View {
    let studyTool: StudyTool
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(radius: 2)
            HStack {
                VStack(alignment: .leading) {
                    Text(studyTool.title).font(.caption).padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    
                    Text("\(studyTool.description)").font(.footnote)
                        .foregroundColor(.darkText)
                    
                }
                .padding(10)
                
                Spacer()
                
                AsyncImage(
                    url: URL(string: studyTool.imageUrl ?? "https://js.design/special/img/figma.png")
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 48)
                } placeholder: {
                    ProgressView()
                        .frame(height: 48)
                }
                .padding(10)
            }
        }.enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    
}

struct StudyToolCell_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolCell(
            
            studyTool: .sample[0]
            
        )
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
