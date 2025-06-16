//
//  StudyToolView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import ComposableArchitecture
import SwiftUI
import Perception
import IsScrolling

struct StudyToolView: View {
    @Bindable var store: StoreOf<StudyToolFeature>
    @State private var hasScrolledToBottom = false
    var body: some View {
        WithPerceptionTracking {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                NavigationView {
                    Group {
                        ZStack {
                            VStack {
                                ScrollViewReader { proxy in
                                    let scrollview =  ScrollView {
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

                                                if  viewStore.toolHistoryListState.isEmpty, let card = viewStore.studyTool.exampleCard {
                                                    ToolQACardView(card: card)
                                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                                }

                                                ForEach(Array(viewStore.toolHistoryListState.enumerated()), id: \.element.id) { index, item in

                                                    let childStore = self.store.scope(
                                                        state: { $0.toolHistoryListState[id: item.id]! },
                                                        action: {.toolHistory(id: item.id, action: $0)}
                                                    )
                                                    ToolHistoryCell(store: childStore)
                                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                                        .id(childStore.id)
                                                        .onAppear {
                                                            viewStore.send(.viewIndex(index))
                                                        }
                                                }

                                            }
                                            .padding(.bottom, viewStore.inputBarState.isKeyboardVisible ? 300 : 0)  // 动态底部间距
                                            .animation(.easeOut, value: viewStore.inputBarState.isKeyboardVisible)

                                        }
                                    }
                                        .scrollDisabled(viewStore.dataLoadingStatus == .loading)
                                        .scrollStatusMonitor($store.isScrolling, monitorMode: .exclusion) // add scrollStatusMonitor to get scroll status
                                        .onChange(of: viewStore.currenttoolHistory) { newValue  in
                                            if nil != newValue, !viewStore.isScrolling, let lastItem = viewStore.toolHistoryListState.last {
                                                proxy.scrollTo(lastItem.id, anchor: .bottom)
                                            }
                                        }
                                    if #available(iOS 17.0, *) {
                                        scrollview.defaultScrollAnchor(.bottom)
                                    } else {
                                        scrollview
                                            .onChange(of: viewStore.toolHistoryListState) { _ in
                                                if !hasScrolledToBottom, let lastItem = viewStore.toolHistoryListState.last {
                                                    proxy.scrollTo(lastItem.id, anchor: .bottom)
                                                    hasScrolledToBottom = true
                                                }
                                            }

                                    }
                                }
                                BottomInputBarBarView(store: store.scope(state: \.inputBarState, action: StudyToolFeature.Action.inputBar))

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
                    .navigationTitle(viewStore.studyTool.title)
                }
            }
        }
    }
}

struct StudyToolView_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolView(
            store: Store(
                initialState: StudyToolFeature.State(
                    studyTool: StudyTool.sample[0]
                ),
                reducer: StudyToolFeature.init
            )
        )
    }
}
