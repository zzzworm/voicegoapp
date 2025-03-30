//
//  GroundedCaptionView.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/30.
//

import SwiftUI

struct GroundedCaptionView: View {
    var caption : String = ""
    var body: some View {
        ZStack(alignment: .center) {
            VStack(){
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .fill(.blue.opacity(0.3))
                    .frame(height:5)
            }
            Text(caption)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                .font(.callout)
                .bold()
        }.fixedSize(horizontal: true, vertical: true)
    }
}


struct GroundedCaptionItemView: View {
    var caption : String = ""
    var body: some View {
        ZStack(alignment: .center) {
            VStack(){
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .fill(.blue.opacity(0.2))
            }
            HStack(){
                Text(caption)
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                    .font(.callout)
                Spacer()
                Image(systemName: "chevron.right")
            }.padding()
        }.fixedSize(horizontal: false, vertical: true)
    }
}


#Preview(body: {
    GroundedCaptionItemView(caption: "如何用")
})
