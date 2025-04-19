// 
//  WaveView.swift
//
//  Created by Den Jo on 2021/04/05.
//  Copyright © nilotic. All rights reserved.
//

import SwiftUI

struct WaveView: View {
    
    // MARK: - Value
    // MARK: Private
    @ObservedObject private var data = WaveData()
    @Binding private var power: CGFloat
    
    
    // MARK: - Initiazlier
    init(data: Binding<CGFloat>) {
        _power = data
    }
    
    
    // MARK: - View
    // MARK: Public
    var body: some View {
        ZStack {
            ForEach(Array(data.colors.enumerated()), id: \.element) { i, color in
                WaveShape(wave: data.waves[i])
                    .fill(color)
            }
        }
        .animation(.easeInOut)
        .blendMode(.lighten)
        .drawingGroup()
        .onChange(of: power) {
            data.update(power: $0)
        }
    }
}

#if DEBUG
struct WaveView_Previews: PreviewProvider {
    
    static var previews: some View {
        @State var power: CGFloat = 0.5
        let view = WaveView(data: $power)
        
        Group {
            view
                .frame(width:100,height: 30)
                .background(Color.gray)
                .preferredColorScheme(.light)
            
            view
                .frame(width:100,height: 30)
                .background(Color.gray)
                .preferredColorScheme(.dark)
        }.onAppear{
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                power = power == 0 ? CGFloat.random(in: 0...1.0) : 0
            }
        }
    }
}
#endif
