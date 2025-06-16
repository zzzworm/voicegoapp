//
//  VoiceAnimatedButton.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/30.
//

import SwiftUI

struct VoiceAnimatedButton: View {
    fileprivate func animateIfNeed() {
        if animating {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { _ in
                step = (step+1)%3
            }
        } else {
            animationTimer?.invalidate()
        }
    }

    @Binding  var animating: Bool
    @State private var step: Int = 0
    @State private var animationTimer: Timer?
    var action: () -> Void?
    var body: some View {
        Button {
            if action != nil {
                action()
            }
        }
        label: {
            if !animating {
                Image(systemName: "speaker.3")
            } else {
                let iconName = "speaker.\(step+1)"
                Image(systemName: iconName)
            }
        }
        .onChange(of: animating) { _ in
            animateIfNeed()
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var animating: Bool = false
    VoiceAnimatedButton(animating: $animating) {

    }.onAppear {
        animating = true
    }
}
