//
//  StudyToolListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolListView: View {
    @Bindable var store: StoreOf<StudyToolsFeature>
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                    VStack {
                        // 切换数据源的按钮
                        HStack {
                            ForEach(StudyTool.ToolTag.allCases, id: \.self) { tag in
                                Button(action: {
                                    store.send(.switchTools(tag))
                                }) {
                                    Text(tag.localizedDescription)
                                        .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
                                        .background(store.state.currentTag == tag ? Color.blue.opacity(0.3) : Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(4)
                                }
                            }

                        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))

                        // 主内容

                            if store.state.dataLoadingStatus == .loading {
                                Spacer()
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            } else if store.state.shouldShowError {
                                ErrorView(
                                    message: "服务器正在开小差，请重试",
                                    retryAction: { store.send(.fetchStudyToolUsedList(store.currentTag))
                                    }
                                )
                            } else {
                                LazyVStack {
                                    ForEach(store.studyToolList) { studyTool in
                                        StudyToolCell(studyTool: studyTool)
                                            .onTapGesture {
                                                store.send(.view(.onToolHistoryTap(studyTool)))
                                            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                            .id(studyTool.id)
                                    }

                                }
                                .listRowInsets(EdgeInsets())
                            }

                        Spacer()
                    }
                    .commonBackground()
                    .navigationTitle("学习工具")
                    .navigationViewStyle(.stack)
                    .navigationBarTitleDisplayMode(.inline)
                    .task {
                        store.send(.fetchStudyToolUsedList(.language_study))
                    }
                }
             destination: { store in
                switch store.case {
                case let .studyTool(store):
                    StudyToolView(store: store)
                        .toolbar(.hidden, for: .tabBar) // Hide tab bar in detail view
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
