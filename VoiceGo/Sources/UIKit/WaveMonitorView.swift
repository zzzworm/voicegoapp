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
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                     startPoint: .top,
                                     endPoint: .bottom))
                .frame( height: value)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        
    }
}

struct WaveMonitorView: View {
    
    @Binding  var soundSamples: [Float]
    private func normalizeSoundLevel(level: Float, height: CGFloat = 300) -> CGFloat {
        let level = max(0.1, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        return CGFloat(level * (height / 25)) // scaled to max at 300 (our height of our bar)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(soundSamples, id: \.self) { level in
                    BarView(value: self.normalizeSoundLevel(level: level, height:geometry.size.height), numberOfSamples: soundSamples.count)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        @State var soundSamples: [Float] = [Float](repeating: 0, count: 10)
        WaveMonitorView(soundSamples: $soundSamples)
            .frame(width: UIScreen.main.bounds.width, height: 30)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}


