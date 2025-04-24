//
//  ToolHistoryDomain.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/27.
//
import Foundation
import ComposableArchitecture
import AVFAudio


struct ToolHistoryDomain: Reducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        let history: ToolConversation
        var isSpeaking : Bool {
            return speakingItem != .none
        }
        enum SpeakingItem {
            case none
            case query
            case answer
        }
        var speakingItem: SpeakingItem = .none
    }
    
    @CasePathable
    enum Action: Equatable,BindableAction {
        case deleteHistory
        case speakQuestion(String)
        case speakAnswer(String)
        case copyAnswer(String)
        case stopSpeak
        case speakFinished
        case speakFailed
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.speechSynthesizer) var speechSynthesizer
    @Dependency(\.clipboardClient) var clipboardClient
    
    fileprivate func speekText(_ answer: String) -> Effect<ToolHistoryDomain.Action> {
        return .run { send in
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
            
            let success = try await speechSynthesizer.speak(utterance)
            if(success){
                await send(.speakFinished)
            }
            else{
                await send(.speakFailed)
            }
        }
    }
    
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .deleteHistory:
                
                return .none
            case .speakQuestion(let question):
                state.speakingItem = .query
                return speekText(question)
            case .speakAnswer(let answer):
                state.speakingItem = .answer
                if let attString = try? AttributedString(
                    markdown:answer
                ){
                    let content = String(attString.characters)
                    return speekText(content)
                }
                else{
                    return .none
                }
            case .stopSpeak:
                return .run { send in
                    let ret =  await speechSynthesizer.stopSpeaking()
                    await send(.speakFailed)
                }
            case .copyAnswer(let answer):
                return .run { send in 
                    clipboardClient.copyValue(answer) 
                }
            case .speakFinished:
                state.speakingItem = .none
                return .none
            case .speakFailed:
                state.speakingItem = .none
                return .none
            
            case .binding(_):
                return .none
            }
        }
    }
}
