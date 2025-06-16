//
//  ContentView.swift
//  SoundVisualizer
//
//  Created by Brandon Baars on 1/22/20.
//  Copyright © 2020 Brandon Baars. All rights reserved.
//

import SwiftUI

struct BarView: View {
    var value: CGFloat
    var numberOfSamples: Int = 10
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: geometry.size.height / 5 )
                    .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                         startPoint: .top,
                                         endPoint: .bottom))
                    .frame( height: value)
            }
            .frame(maxHeight: .infinity) // 关键点
        }

        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct WaveMonitorView: View {

    @Binding  var soundSamples: [Float]
    private func normalizeSoundLevel(level: Float, height: CGFloat = 300) -> CGFloat {
        let level = max(0.1, CGFloat(level) + 50) / 2 // between 0.1 and 25

        return CGFloat(level * (height / 25)) // scaled to max at 300 (our height of our bar)
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: (geometry.size.width / CGFloat(soundSamples.count)/3.0)) {
                ForEach(soundSamples, id: \.self) { level in
                        BarView(value: self.normalizeSoundLevel(level: level, height: geometry.size.height), numberOfSamples: soundSamples.count)
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        @State var soundSamples: [Float] = (0 ..< 10).map { _ in Float.random(in: -50...0) }
        WaveMonitorView(soundSamples: $soundSamples)
            .frame(width: UIScreen.main.bounds.width, height: 30)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}
