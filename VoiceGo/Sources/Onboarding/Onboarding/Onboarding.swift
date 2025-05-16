//
//  Onboarding.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 31.03.23.
//

import SwiftUI

struct Onboarding: Hashable, Identifiable {
    enum Tab: CaseIterable {
        case page1, page2, page3
    }

    let id: Int
    let lottie: String
    let title: String
    let description: String
    let tab: Tab
}

extension Onboarding {

    static let pages: [Onboarding] = [
        Onboarding(id: 0,
                   lottie: "onboarding_1",
                   title: String(localized: "与AI对话,让学习更轻松"),
                   description: String(localized:"摆脱尴尬,社恐福音.与AI外教随时对话,让你轻松练口语."),
                   tab: .page1),
        
        Onboarding(id: 1,
                   lottie: "onboarding_2",
                   title: String(localized:"多种AI工具,工作学习更轻松"),
                   description: String(localized:"从翻译到写作,无论是学习还是工作,让你事半功倍."),
                   tab: .page2),
        
        Onboarding(id: 2,
                   lottie: "onboarding_3",
                   title: String(localized:"趣味和专项练习,让学习更高效"),
                   description: String(localized:"通过趣味和专项练习,让你在轻松中提升英语水平."),
                   tab: .page3),
    ]
}

