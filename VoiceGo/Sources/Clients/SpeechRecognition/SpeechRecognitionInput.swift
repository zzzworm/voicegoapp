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
    }
    
    enum Action : Equatable {
        static func == (lhs: SpeechRecognitionInputDomain.Action, rhs: SpeechRecognitionInputDomain.Action) -> Bool {
            return false
        }
        
        case alert(PresentationAction<Alert>)
        case recordButtonTapped
        case speech(Result<String, any Error>)
        case speechRecognizerAuthorizationStatusResponse(SFSpeechRecognizerAuthorizationStatus)
        
        enum Alert: Equatable {}
    }
    
    @Dependency(\.speechClient) var speechClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert:
                return .none
                
            case .recordButtonTapped:
                state.isRecording.toggle()
                
                guard state.isRecording
                else {
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
                    for try await result in await self.speechClient.startTask(request) {
                        await send(
                            .speech(.success(result.bestTranscription.formattedString)), animation: .linear)
                    }
                } catch: { error, send in
                    await send(.speech(.failure(error)))
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
        
            Button {
                store.send(.recordButtonTapped)
            } label: {
                    Image(
                        systemName: store.isRecording
                        ? "mic.fill" : "mic"
                    )
                    .font(.headline)
    
                    .foregroundColor(.black)
                    .padding(8)
                .background(.gray.opacity(0.4))
                .cornerRadius(10)
            }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    SpeechRecognitionInputView(
        store: Store(initialState: SpeechRecognitionInputDomain.State(transcribedText: "")) {
            SpeechRecognitionInputDomain()
        }
    )
}
