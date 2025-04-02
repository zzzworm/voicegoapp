//
//  StudyToolView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import ComposableArchitecture
import SwiftUI


struct InputBarDomain : Reducer{
    @ObservableState
    struct State : Equatable {
        var inputText: String = ""
        var isKeyboardVisible: Bool = false
        var speechRecognitionInputState: SpeechRecognitionInputDomain.State = .init()
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case inputTextChanged(String)
        case speechRecognitionInput(SpeechRecognitionInputDomain.Action)
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
                return .none
            }
        }
    }
}

struct BottomInputBarBarView: View {
    @FocusState var isFocused : Bool // 1
    @Perception.Bindable var store: StoreOf<InputBarDomain>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .center) {
                HStack {
                    // 添加按钮
                    SpeechRecognitionInputView(store: store.scope(state: \.speechRecognitionInputState, action: InputBarDomain.Action.speechRecognitionInput))
                    
                    // 添加输入框
                    TextField(
                        "请输入内容",
                        text: viewStore.binding(
                            get: \.inputText,
                            send: InputBarDomain.Action.inputTextChanged
                        )
                    )
                    .focused($isFocused) // 2
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                }.padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                
            }
            // Synchronize store focus state and local focus state.
            .bind($store.isKeyboardVisible, to: $isFocused)
        }
    }
}

struct StudyToolView: View {
    let store: StoreOf<StudyToolDomain>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    ZStack{
                        
                        VStack {
                            ScrollView {
                                if viewStore.dataLoadingStatus == .loading {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                } else if viewStore.shouldShowError {
                                    ErrorView(
                                        message: "Oops, we couldn't fetch product list",
                                        retryAction: { viewStore.send(.fetchStudyHistory) }
                                    )
                                    
                                } else {
                                    
                                    LazyVStack {
                                        if 0 == viewStore.toolHistoryListState.count {
                                            ToolQACardView(card: viewStore.card)
                                        }
                                        
                                        ForEachStore(
                                            self.store.scope(
                                                state: \.toolHistoryListState,
                                                action: StudyToolDomain.Action.toolHistory
                                            )
                                        ) { store in
                                            ToolHistoryCell(store: store)
                                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                        }
                                    }
                                    .padding(.bottom, viewStore.inputBarState.isKeyboardVisible ? 300 : 0)  // 动态底部间距
                                    .animation(.easeOut, value: viewStore.inputBarState.isKeyboardVisible)
                                }
                            }
                            
                            BottomInputBarBarView(store: store.scope(state: \.inputBarState, action: StudyToolDomain.Action.inputBar))
                            Text("AI生成内容，仅供参考")
                        }
                        .onTapGesture {
                            viewStore.send(.inputBar(.set(\.isKeyboardVisible, false)))
                        }
                        
                    }
                    .task {
                        viewStore.send(.fetchStudyHistory)
                    }
                    .navigationTitle(viewStore.studyTool.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationViewStyle(.stack)
                    
                }
                
            }
        }
    }
}

struct StudyToolView_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolView(
            store: Store(
                initialState: StudyToolDomain.State(
                    id: UUID(), studyTool: StudyTool.sample[0],
                    card: QACard(
                        isExample: true, originText: "apply", actionText: "翻译", answer: "应用")),
                reducer: StudyToolDomain.init
            )
        )
    }
}


