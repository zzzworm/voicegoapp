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
        
            HStack {
                VStack(alignment: .leading) {
                    Text(studyTool.title).font(.system(.title, design: .rounded))
         
                        Text("\(studyTool.description)").font(.system(.body, design: .rounded))

                }
                .padding(10)

                Spacer()
                
                AsyncImage(
                    url: URL(string: studyTool.imageUrl)
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

struct StudyToolCell_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolCell(
           
                    studyTool: .sample[0]
            
        )
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
