//
//  ProfileCell.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/13.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//
import SwiftUI
import Nuke
import NukeUI

struct ProfileCell : View {
    let profile : UserProfile
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                LazyImage(url: URL(string: profile.userIconUrl))
                    .frame(width: 34, height: 34)
                VStack{
                    Spacer()
                    Text(profile.phoneNumber)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(profile.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                Spacer()
                Button(action: action) {
                    Text("立即开通").padding(6)
                }.background(Color.gray.opacity(0.4))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(6)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
        }
    }
}


struct ProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCell(profile:UserProfile.default) {
            print("Button tapped!")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
