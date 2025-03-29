//
//  ToolHistoryDomain.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//
import Foundation
import ComposableArchitecture
import AVFAudio
import UIKit

struct ToolHistoryDomain: Reducer {
    struct State: Equatable, Identifiable {
        let id: UUID
        
        let history: ToolHistory
        
    }
    
    enum Action: Equatable {
        case deleteHistory
        case speakAnswer(String)
        case copyAnswer(String)
    }

    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .deleteHistory:
                
                return .none
                
            case .speakAnswer(let answer):
                UIPasteboard.general.string = answer
                return .none
            case .copyAnswer(let answer):
                // Create an utterance.
                let utterance = AVSpeechUtterance(string: answer)


                // Configure the utterance.
                utterance.rate = 0.57
                utterance.pitchMultiplier = 0.8
                utterance.postUtteranceDelay = 0.2
                utterance.volume = 0.8


                // Retrieve the British English voice.
                let voice = AVSpeechSynthesisVoice(language: "zh-CN")


                // Assign the voice to the utterance.
                utterance.voice = voice
                // Create a speech synthesizer.
                let synthesizer = AVSpeechSynthesizer()


                // Tell the synthesizer to speak the utterance.
                synthesizer.speak(utterance)
                return .none
            }
        }
    }
}
