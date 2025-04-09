import ComposableArchitecture
import Speech
import Accelerate

extension SpeechClient: DependencyKey {
    static var liveValue: Self {
        let speech = Speech()
        return Self(
            finishTask: {
                await speech.finishTask()
            },
            requestAuthorization: {
                await withCheckedContinuation { continuation in
                    SFSpeechRecognizer.requestAuthorization { status in
                        continuation.resume(returning: status)
                    }
                }
            },
            startTask: { request,onAudioLevelChanged  in
                let request = UncheckedSendable(request)
                return await speech.startTask(request: request, onAudioLevelChanged: onAudioLevelChanged)
            }
        )
    }
}

private actor Speech {
    var audioEngine: AVAudioEngine? = nil
    var recognitionTask: SFSpeechRecognitionTask? = nil
    var recognitionContinuation: AsyncThrowingStream<SpeechRecognitionResult, any Error>.Continuation?
    
    var averagePowerForChannel0: Float = 0
    var averagePowerForChannel1: Float = 0
    let LEVEL_LOWPASS_TRIG:Float32 = 0.30
    
    
    func finishTask() {
        self.audioEngine?.stop()
        self.audioEngine?.inputNode.removeTap(onBus: 0)
        self.recognitionTask?.finish()
        self.recognitionContinuation?.finish()
    }
    
    private func audioMetering(buffer:AVAudioPCMBuffer) {
        buffer.frameLength = 1024
        let inNumberFrames:UInt = UInt(buffer.frameLength)
        if buffer.format.channelCount > 0 {
            let samples = (buffer.floatChannelData![0])
            var avgValue:Float32 = 0
            vDSP_meamgv(samples,1 , &avgValue, inNumberFrames)
            var v:Float = -100
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            self.averagePowerForChannel0 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel0)
            self.averagePowerForChannel1 = self.averagePowerForChannel0
        }
        
        if buffer.format.channelCount > 1 {
            let samples = buffer.floatChannelData![1]
            var avgValue:Float32 = 0
            vDSP_meamgv(samples, 1, &avgValue, inNumberFrames)
            var v:Float = -100
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            self.averagePowerForChannel1 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel1)
        }
    }
    
    func startTask(
        request: UncheckedSendable<SFSpeechAudioBufferRecognitionRequest>, onAudioLevelChanged: ((Float) -> Void)?
    ) -> AsyncThrowingStream<SpeechRecognitionResult, any Error> {
        let request = request.wrappedValue
        return AsyncThrowingStream { continuation in
            self.recognitionContinuation = continuation
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                continuation.finish(throwing: SpeechClient.Failure.couldntConfigureAudioSession)
                return
            }
            
            self.audioEngine = AVAudioEngine()
            let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                switch (result, error) {
                case let (.some(result), _):
                    continuation.yield(SpeechRecognitionResult(result))
                case (_, .some):
                    continuation.finish(throwing: SpeechClient.Failure.taskError)
                case (.none, .none):
                    fatalError("It should not be possible to have both a nil result and nil error.")
                }
            }
            
            continuation.onTermination = {
                [
                    speechRecognizer = UncheckedSendable(speechRecognizer),
                    audioEngine = UncheckedSendable(audioEngine),
                    recognitionTask = UncheckedSendable(recognitionTask)
                ]
                _ in
                
                _ = speechRecognizer
                audioEngine.wrappedValue?.stop()
                audioEngine.wrappedValue?.inputNode.removeTap(onBus: 0)
                recognitionTask.wrappedValue?.finish()
            }
            
            self.audioEngine?.inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: self.audioEngine?.inputNode.outputFormat(forBus: 0)
            ) { [weak self] (buffer, when) in
                guard let strongSelf = self else {
                                    return
                                }
                request.append(buffer)
                strongSelf.audioMetering(buffer: buffer)
                onAudioLevelChanged?(strongSelf.averagePowerForChannel0)
            }
            
            self.audioEngine?.prepare()
            do {
                try self.audioEngine?.start()
            } catch {
                continuation.finish(throwing: SpeechClient.Failure.couldntStartAudioEngine)
                return
            }
        }
    }
    

}
