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
                                        message: "Oops, we couldn't fetch things",
                                        retryAction: {
                                            viewStore.send(.fetchStudyHistory(page: 1, pageSize: 10))
                                        }
                                    )
                                    
                                } else {
                                    
                                    LazyVStack {
                                        if 0 == viewStore.toolHistoryListState.count , let card = viewStore.card {
                                            ToolQACardView(card: card)
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
                    .navigationTitle(viewStore.studyTool.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationViewStyle(.stack)
                    
                }.task {
                    viewStore.send(.fetchStudyHistory(page: 1, pageSize: 10))
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
                    studyToolUsedID: "xxdfsdfas", studyTool: StudyTool.sample[0],
                    card: QACard(id:0  ,
                                 isExample: true, originText: "apply", actionText: "翻译", suggestions: ["应用"])),
                reducer: StudyToolDomain.init
            )
        )
    }
}


