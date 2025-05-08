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
                    Text(studyTool.title).font(.headline).padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
         
                    Text("\(studyTool.description)").font(.body)
                        .foregroundColor(.gray)

                }
                .padding(10)

                Spacer()
                
                AsyncImage(
                    url: URL(string: studyTool.imageUrl)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                } placeholder: {
                    ProgressView()
                        .frame(height: 40)
                }
                
            }.padding(10)
            
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
