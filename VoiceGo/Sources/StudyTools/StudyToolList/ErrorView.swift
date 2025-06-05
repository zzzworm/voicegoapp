//
//  ErrorView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import SwiftUI
import UIFontComplete

struct ErrorView: View {
    let message: String
    let systemMessage: String = String(localized:"请检查网络连接或稍后重试", comment: "Error message when there is a network issue")
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Image(VoiceGoAsset.Assets.errorLogo.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding(.top, 50)
            Text(message)
                .font(BuiltInFont.helvetica.of(size: 26.0))
                .padding(16)
                
            Text(systemMessage)
                .font(BuiltInFont.helvetica.of(size: 16.0))
                .padding(16)
            Spacer()
            let selectedStyle = CTAButtonStyle(isSelected: true)
            Button {
                retryAction()
            } label: {
                Text("重试")
                    .font(.custom("AmericanTypewriter", size: 25))
                    .foregroundColor(.white)
            }
            .buttonStyle(selectedStyle)
            .frame(width:100)
            .padding(.bottom,16)

        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            message: "Oops, we couldn't fetch product list",
            retryAction: {}
        )
            
    }
}
