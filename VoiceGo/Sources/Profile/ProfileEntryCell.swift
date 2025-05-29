//
//  ProfileEntryCell.swift
//  VoiceGo
//
//  Created by admin on 2025/5/29.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import SwiftUI

struct ProfileEntryButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct ProfileEntryCell: View {
    var body: some View {
        HStack {
            Spacer()
            ProfileEntryButton(
                icon: "book.fill",
                title: "学习记录"
            ) {
                print("学习记录")
            }
            Spacer()
            ProfileEntryButton(
                icon: "star.fill",
                title: "收藏"
            ) {
                print("收藏")
            }
            Spacer()
            ProfileEntryButton(
                icon: "clock.fill",
                title: "历史"
            ) {
                print("历史")
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    ProfileEntryCell()
}

