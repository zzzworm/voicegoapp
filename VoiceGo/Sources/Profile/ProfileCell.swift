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
import ComposableArchitecture

struct ProfileCell : View {
    let profile : UserProfile
//    @Dependency(\.clipboardClient) var clipboardClient
    
    var action: () -> Void
    
    var body: some View {
        VStack{
            ZStack{
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .foregroundColor(.gray)
                    .cornerRadius(64)
                if let iconUrl = profile.userIconUrl
                {
                    LazyImage(url: URL(string: iconUrl))
                        .scaledToFit()
                        .frame(width: 128, height: 128)
                        .foregroundColor(.gray)
                        .cornerRadius(64)
                }
            }
            HStack {
                
                
                VStack(alignment: .center){
                    
                    if let phoneNumber = profile.displayIdenifier{
                        Text(phoneNumber)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                   
                    Text(profile.username)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

            }
            Button(action: action) {
                Text("编辑资料").padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
            }.background(Color.gray.opacity(0.4))
                .foregroundColor(.black)
                .cornerRadius(8)
            
            /*
            HStack{
                Text("用户ID：")
                    .foregroundColor(.primary)
                Text("\(profile.id)")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "doc.on.clipboard")
                    .frame(width:26)
            }
            .onTapGesture{
                clipboardClient.copyValue("\(profile.id)")
            }
             */
        }
        .padding()
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
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
