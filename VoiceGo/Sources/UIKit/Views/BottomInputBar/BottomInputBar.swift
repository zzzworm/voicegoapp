//
//  BottomInputBar.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/2.
//

import SwiftUI
import ComposableArchitecture

struct BottomInputBarFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var text: String = ""
        var placeholdr: String = "对话，查词，翻译，问答"
        var isKeyboardVisible: Bool = false
        var speechRecognitionInputState: SpeechRecognitionInputDomain.State = .init()
        var speechMode = false
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case textChanged(String)
        case submitText(String)
        case speechRecognitionInput(SpeechRecognitionInputDomain.Action)
        case toggleSpeechMode
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.speechRecognitionInputState, action: /Action.speechRecognitionInput) {
            SpeechRecognitionInputDomain()
        }
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .textChanged(let text):
                state.text = text
                return .none
            case .speechRecognitionInput(let action):
                switch action {
                case .binding:
                    break
                case .alert, .recordButtonTapped, .recordButtonReleased:
                    break
                case .speech(let result):
                    switch result {
                    case .success(let text):
                        return .send(.submitText(text))
                    case .failure(let error):
                        print("Error transcribing speech: \(error)")
                    }

                case .speechRecognizerAuthorizationStatusResponse:
                    break
                case .soundLeveUpdate:
                    return .none
                }
                return .none
            case .toggleSpeechMode:
                state.speechMode.toggle()
                return .none
            case .submitText(let text):
                state.text = ""
                return .none
            }
        }
    }
}

struct BottomInputBarBarView: View {
    @FocusState var isFocused: Bool // 1
    @Bindable var store: StoreOf<BottomInputBarFeature>
    var body: some View {
        WithPerceptionTracking {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                VStack(alignment: .center) {
                    HStack {
                        Button {
                            store.send(.toggleSpeechMode)
                        } label: {
                            Image(
                                systemName: viewStore.speechMode
                                ? "keyboard" : "mic"
                            )
                            .font(.headline)
                            .foregroundColor(.black)
                        }
                        .frame(width: 30)

                        if viewStore.speechMode {

                            SpeechRecognitionInputView(store: store.scope(state: \.speechRecognitionInputState, action: BottomInputBarFeature.Action.speechRecognitionInput))
                                .frame(maxHeight: 30)
                        } else {
                            // 添加输入框

                            TextField(
                                store.state.placeholdr,
                                text: viewStore.binding(
                                    get: \.text,
                                    send: BottomInputBarFeature.Action.textChanged
                                ),
                                axis: .vertical
                            )
                            .lineLimit(15)
                            .focused($isFocused) // 2
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                viewStore.send(.submitText(viewStore.text))
                            }
                        }
                    }
                    .frame(minHeight: 30)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))

                }
                // Synchronize store focus state and local focus state.
                .bind($store.isKeyboardVisible, to: $isFocused)
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct BottomInputBarBarView_Previews: PreviewProvider {
    // Add preview
    @FocusState var focus: Bool
    static var previews: some View {
        BottomInputBarBarView(store: Store(
            initialState: BottomInputBarFeature.State(), reducer: BottomInputBarFeature.init))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
