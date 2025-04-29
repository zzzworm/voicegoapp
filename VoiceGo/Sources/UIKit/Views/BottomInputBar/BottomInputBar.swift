//
//  BottomInputBar.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/2.
//

import SwiftUI
import ComposableArchitecture

struct BottomInputBarDomain : Reducer{
    @ObservableState
    struct State : Equatable {
        var inputText: String = ""
        var isKeyboardVisible: Bool = false
        var speechRecognitionInputState: SpeechRecognitionInputDomain.State = .init()
        var speechMode = false
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case inputTextChanged(String)
        case submitText(String)
        case speechRecognitionInput(SpeechRecognitionInputDomain.Action)
        case toggleSpeechMode
    }
    
    
    
    var body: some ReducerOf<Self>  {
        BindingReducer()
        Scope(state: \.speechRecognitionInputState, action: /Action.speechRecognitionInput) {
            SpeechRecognitionInputDomain()
        }
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .inputTextChanged(let text):
                state.inputText = text
                return .none
            case .speechRecognitionInput(let action):
                switch action {
                case .binding(_):
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
                    
                case .speechRecognizerAuthorizationStatusResponse(_):
                    break
                case .soundLeveUpdate(_):
                    return .none
                }
                return .none
            case .toggleSpeechMode:
                state.speechMode.toggle()
                return .none
            case .submitText(let text):
                state.inputText = text
                return .none
            }
        }
    }
}

struct BottomInputBarBarView: View {
    @FocusState var isFocused : Bool // 1
    @Perception.Bindable var store: StoreOf<BottomInputBarDomain>
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
                        
                        if (viewStore.speechMode){
                            
                            SpeechRecognitionInputView(store: store.scope(state: \.speechRecognitionInputState, action: BottomInputBarDomain.Action.speechRecognitionInput))
                                .frame(maxHeight: 30)
                        }
                        else{
                            // 添加输入框
                            
                            TextField(
                                "请输入内容",
                                text: viewStore.binding(
                                    get: \.inputText,
                                    send: BottomInputBarDomain.Action.inputTextChanged
                                )
                            )
                            .focused($isFocused) // 2
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit{
                                viewStore.send(.submitText(viewStore.inputText))
                            }
                            .frame(maxHeight: 30)
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    .frame(maxHeight: 30)
                    
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
    //Add preview
    @FocusState var focus: Bool
    static var previews: some View {
        BottomInputBarBarView(store: Store(
            initialState:BottomInputBarDomain.State(), reducer: BottomInputBarDomain.init))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
