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
    private enum BackgroudID { case backgroud }
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                WithViewStore(self.store, observe: { $0 }) { viewStore in
                    VStack {
                        // 切换数据源的按钮
                        HStack {
                            ForEach(StudyTool.ToolTag.allCases, id:\.self){ tag in
                                Button(action: {
                                    viewStore.send(.switchTools(tag))
                                }) {
                                    Text(tag.localizedDescription)
                                        .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
                                        .background(viewStore.currentTag == tag ? Color.blue.opacity(0.3) : Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(4)
                                }
                            }
                            
                        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                        
                        // 主内容
                        
                            if viewStore.dataLoadingStatus == .loading {
                                Spacer()
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            } else if viewStore.shouldShowError {
                                ErrorView(
                                    message: "服务器正在开小差，请重试",
                                    retryAction: { viewStore.send(.fetchStudyToolUsedList(viewStore.currentTag))
                                    }
                                )
                            } else {
                                LazyVStack {
                                    ForEach(viewStore.studyToolList) { studyTool in
                                        StudyToolCell(studyTool: studyTool)
                                            .onTapGesture {
                                                viewStore.send(.view(.onToolHistoryTap(studyTool)))
                                            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                            .id(studyTool.id)
                                    }
                                    
                                }
                                .listRowInsets(EdgeInsets())
                            }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        
                        LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), .white]),
                        startPoint: .top,
                        endPoint: .bottom
                        ).id(BackgroudID.backgroud)
                            .ignoresSafeArea()
                    )
                    .navigationTitle("学习工具")
                    .navigationViewStyle(.stack)
                    .navigationBarTitleDisplayMode(.inline)
                    .task {
                        viewStore.send(.fetchStudyToolUsedList(.language_study))
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
