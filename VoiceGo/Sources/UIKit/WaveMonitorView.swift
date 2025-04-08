//
//  ContentView.swift
//  SoundVisualizer
//
//  Created by Brandon Baars on 1/22/20.
//  Copyright © 2020 Brandon Baars. All rights reserved.
//

import SwiftUI


class SampleMonitor : ObservableObject{
    @Published public var soundSamples: [Float]
    var numberOfSamples: Int = 10
    init(numberOfSamples: Int = 10) {
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.numberOfSamples = numberOfSamples // In production check this is > 0.

    }
}


struct BarView: View {
    var value: CGFloat
    var numberOfSamples: Int = 10
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                     startPoint: .top,
                                     endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples), height: value)
        }
    }
}

struct WaveMonitorView: View {
    
    @ObservedObject var soundMonitor : SampleMonitor = SampleMonitor()
    private func normalizeSoundLevel(level: Float, height: CGFloat = 300) -> CGFloat {
        let level = max(0.1, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        return CGFloat(level * (height / 25)) // scaled to max at 300 (our height of our bar)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(soundMonitor.soundSamples, id: \.self) { level in
                    BarView(value: self.normalizeSoundLevel(level: level, height:geometry.size.height), numberOfSamples: soundMonitor.numberOfSamples)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        @ObservedObject  var mic = SampleMonitor()
        WaveMonitorView(soundMonitor: mic)
    }
}


