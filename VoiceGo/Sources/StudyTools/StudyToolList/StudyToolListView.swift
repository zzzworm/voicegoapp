//
//  StudyToolListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolListView: View {
    @Perception.Bindable var store: StoreOf<StudyToolsFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                WithViewStore(self.store, observe: { $0 }) { viewStore in
                    VStack {
                        // 切换数据源的按钮
                        HStack {
                            Button(action: {
                                viewStore.send(.switchToUsedTools)
                            }) {
                                Text("已使用工具")
                                    .padding()
                                    .background(viewStore.isShowingUsedTools ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                viewStore.send(.switchToAvailableTools)
                            }) {
                                Text("可用工具")
                                    .padding()
                                    .background(!viewStore.isShowingUsedTools ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()

                        // 主内容
                        Group {
                            if viewStore.dataLoadingStatus == .loading {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            } else if viewStore.shouldShowError {
                                ErrorView(
                                    message: "Oops, we couldn't fetch the tool list",
                                    retryAction: { viewStore.send(.fetchCurrentToolList) }
                                )
                            } else {
                                List {
                                    ForEach(viewStore.currentToolList) { studyTool in
                                        StudyToolCell(studyTool: studyTool)
                                            .onTapGesture {
                                                viewStore.send(.view(.onToolHistoryTap(studyTool)))
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("学习工具")
                    .navigationViewStyle(.stack)
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewStore.send(.fetchCurrentToolList)
                    }
                }
            } destination: { store in
                switch store.case {
                case let .studyTool(store):
                    StudyToolView(store: store)
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct StudyToolListView_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolListView(
            store: Store(
                initialState: StudyToolsFeature.State(),
                reducer: StudyToolsFeature.init
            )
        )
    }
}
