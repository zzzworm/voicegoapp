//
//  AVAudioPCMBuffer+Extensions.swift
//  SleepSentry
//
//  Created by Selina on 8/4/2023.
//

import AVFAudio
import Foundation
import Accelerate

public extension AVAudioPCMBuffer {
    var rms: Float {
        guard let data = floatChannelData else { return 0 }
        
        let channelCount = Int(format.channelCount)
        var rms: Float = 0.0
        for i in 0 ..< channelCount {
            var channelRms: Float = 0.0
            vDSP_rmsqv(data[i], 1, &channelRms, vDSP_Length(frameLength))
            rms += abs(channelRms)
        }
        let value = (rms / Float(channelCount))
        return value
    }
    
    var db: Float {
        let avgPower = 20 * log10(rms)
        guard avgPower.isFinite else {
            return 0
        }
        
        return avgPower
    }
    
    var meterLevel: Float {
        let power = db
        
        var level: Float = 0
        let minDb: Float = -80
        if power < minDb {
            level = 0
        } else if power >= 1.0 {
            level = 1
        } else {
            level = (abs(minDb) - abs(power)) / abs(minDb)
        }
        
        return level
    }
    
    var uint8MeterLevel: UInt8 {
        let level = meterLevel
        return UInt8(255 * level)
    }
    
    var averagePower:[Float] {
        var power:[Float] = []
        guard let data = floatChannelData else { return power }
        let channelCount = Int(format.channelCount)
        for i in 0 ..< channelCount {
            let samples = (data[i])
            var avgValue:Float32 = 0
            vDSP_meamgv(samples,1 , &avgValue, vDSP_Length(frameLength))
            var v:Float = -100
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            power.append(v)
        }
        return power
    }

}
