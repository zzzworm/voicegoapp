//
//  StudyToolView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import ComposableArchitecture
import SwiftUI


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
                            Text("AI生成内容，仅供参考").padding(.bottom, 5)
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


