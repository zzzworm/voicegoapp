//
//  StudyToolView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import ComposableArchitecture
import SwiftUI

struct StudyToolBottomBarView: View {
    let viewStore: ViewStore<StudyToolDomain.State, StudyToolDomain.Action>
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                // 添加按钮
                Button {
                    viewStore.send(.fetchStudyHistory)
                } label: {
                    Image(systemName: "mic")
                        .font(.title)
                }
                
                // 添加输入框
                TextField(
                    "请输入内容",
                    text: viewStore.binding(
                        get: \.inputText,
                        send: StudyToolDomain.Action.inputTextChanged
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: UIResponder.keyboardWillShowNotification,
                        object: nil, queue: .main
                    ) { _ in
                        viewStore.send(.keyboardWillShow)
                    }
                    NotificationCenter.default.addObserver(
                        forName: UIResponder.keyboardWillHideNotification,
                        object: nil, queue: .main
                    ) { _ in
                        viewStore.send(.keyboardWillHide)
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(
                        self, name: UIResponder.keyboardWillShowNotification,
                        object: nil)
                    NotificationCenter.default.removeObserver(
                        self, name: UIResponder.keyboardWillHideNotification,
                        object: nil)
                }
            }.padding()
            Text("AI生成内容，仅供参考")
        }
    }
}

struct StudyToolView: View {
    let store: StoreOf<StudyToolDomain>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    VStack {
//                        ScrollView {
//                            if viewStore.dataLoadingStatus == .loading {
//                                ProgressView()
//                                    .frame(width: 100, height: 100)
//                            } else if viewStore.shouldShowError {
//                                ErrorView(
//                                    message: "Oops, we couldn't fetch product list",
//                                    retryAction: { viewStore.send(.fetchStudyHistory) }
//                                )
//
//                            } else {
//
//                                LazyVStack {
//                                    if 0 == viewStore.toolHistoryListState.count {
//                                        ToolQACardView(card: viewStore.card)
//                                    }
//
//                                    ForEachStore(
//                                        self.store.scope(
//                                            state: \.toolHistoryListState,
//                                            action: StudyToolDomain.Action.toolHistory
//                                        )
//                                    ) { store in
//                                        let cell = ToolHistoryCell(store: store)
//                                        VStack {
//                                            cell
//                                        }.padding(.horizontal, 5, .vertical, 8)
//                                    }
//
//                                }
////                                .padding(.bottom, viewStore.isKeyboardVisible ? 300 : 0)  // 动态底部间距
////                                .animation(.easeOut, value: viewStore.isKeyboardVisible)
//
//                            }
//                        }
                        StudyToolBottomBarView(viewStore: viewStore)
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


