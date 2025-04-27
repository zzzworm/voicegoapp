//
//  LoaderModifier.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 17.07.23.
//

import SwiftUI

struct LoaderModifier: ViewModifier {

    var isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 10 : 0)

            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(.main)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(Color.primary)
                .opacity(isLoading ? 1 : 0)
            }
        }
    }
}

extension View {
    func loader(isLoading: Bool) -> some View {
        modifier(LoaderModifier(isLoading: isLoading))
    }
}


// 定义一个PreferenceKey
struct UIRefreshedPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
