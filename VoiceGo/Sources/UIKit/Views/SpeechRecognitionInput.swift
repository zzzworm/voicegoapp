import ComposableArchitecture
import Speech
import SwiftUI


@Reducer
struct SpeechRecognitionInputDomain {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
        var isRecording = false
        var transcribedText = ""
        var currentSample: Int = 0
        var numberOfSamples: Int = 10
        var soundSamples: [Float] = [Float](repeating: -30.0, count: 10)
    }
    
    enum Action : Equatable, BindableAction {
        static func == (lhs: SpeechRecognitionInputDomain.Action, rhs: SpeechRecognitionInputDomain.Action) -> Bool {
            return false
        }
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case recordButtonTapped
        case recordButtonReleased
        case speech(Result<String, any Error>)
        case speechRecognizerAuthorizationStatusResponse(SFSpeechRecognizerAuthorizationStatus)
        case soundLeveUpdate(Float)
        enum Alert: Equatable {}
    }
    
    @Dependency(\.speechClient) var speechClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .alert:
                return .none
            case .soundLeveUpdate(let level):
                state.soundSamples[state.currentSample] = level
                state.currentSample = (state.currentSample + 1) % state.numberOfSamples
                return .none
            case .recordButtonTapped:
                
                guard !state.isRecording else {
                    state.isRecording = false
                    return .run { _ in
                        await self.speechClient.finishTask()
                    }
                }
                
                return .run { send in
                    let status = await self.speechClient.requestAuthorization()
                    await send(.speechRecognizerAuthorizationStatusResponse(status))
                    
                    guard status == .authorized
                    else { return }
                    let request = SFSpeechAudioBufferRecognitionRequest()
                    for try await result in await self.speechClient.startTask(request: request,
                                                                              onAudioLevelChanged: { level in
                        // Handle audio level changes if needed
                        DispatchQueue.main.async {
                            send(.soundLeveUpdate(level))
                        }
                    }) {
                        await send(
                            .speech(.success(result.bestTranscription.formattedString)), animation: .linear)
                    }
                } catch: { error, send in
                    await send(.speech(.failure(error)))
                }
            case .recordButtonReleased:
                state.isRecording = false
                return .run { _ in
                    await self.speechClient.finishTask()
                }
            case .speech(.failure(SpeechClient.Failure.couldntConfigureAudioSession)),
                    .speech(.failure(SpeechClient.Failure.couldntStartAudioEngine)):
                state.alert = AlertState { TextState("Problem with audio device. Please try again.") }
                return .none
                
            case .speech(.failure):
                state.alert = AlertState {
                    TextState("An error occurred while transcribing. Please try again.")
                }
                return .none
                
            case let .speech(.success(transcribedText)):
                state.transcribedText = transcribedText
                return .none
                
            case let .speechRecognizerAuthorizationStatusResponse(status):
                state.isRecording = status == .authorized
                
                switch status {
                case .authorized:
                    return .none
                    
                case .denied:
                    state.alert = AlertState {
                        TextState(
              """
              You denied access to speech recognition. This app needs access to transcribe your \
              speech.
              """
                        )
                    }
                    return .none
                    
                case .notDetermined:
                    return .none
                    
                case .restricted:
                    state.alert = AlertState { TextState("Your device does not allow speech recognition.") }
                    return .none
                    
                @unknown default:
                    return .none
                }
            case .binding(_):
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        
    }
}

struct SpeechRecognitionInputView: View {
    
#if os(macOS)
    @Bindable var store: StoreOf<SpeechRecognitionInputDomain>
#else
    @Perception.Bindable var store: StoreOf<SpeechRecognitionInputDomain>
#endif
    var body: some View {
        WithPerceptionTracking {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                ZStack(alignment: .center){
                    if(viewStore.isRecording){
                        HStack{
                            Spacer()
                                .frame(maxWidth: .infinity)
                            WaveMonitorView(soundSamples: $store.soundSamples)
                                .frame(maxWidth: .infinity)
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    else{
                        Text("按住说话")
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .fixedSize(horizontal: false, vertical: true)
                            .background(.gray.opacity(0.4))
                            .alert($store.scope(state: \.alert, action: \.alert))
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ _ in
                            if !viewStore.isRecording {
                                store.send(.recordButtonTapped)
                            }
                        })
                        .onEnded({ _ in
                            store.send(.recordButtonReleased)
                        })
                )
            }
        }
    }
}

#Preview {
    SpeechRecognitionInputView(
        store: Store(initialState: SpeechRecognitionInputDomain.State(transcribedText: "")) {
            SpeechRecognitionInputDomain()
        }
    )
}
