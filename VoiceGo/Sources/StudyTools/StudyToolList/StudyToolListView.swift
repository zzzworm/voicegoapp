//
//  StudyToolListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolListView: View {
    @Perception.Bindable var store: StoreOf<StudyToolListDomain>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                WithViewStore(self.store, observe: { $0 }) { viewStore in
                    NavigationView {
                        Group {
                            if viewStore.dataLoadingStatus == .loading {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            } else if viewStore.shouldShowError {
                                ErrorView(
                                    message: "Oops, we couldn't fetch product list",
                                    retryAction: { viewStore.send(.fetchStudyToolUsedList) }
                                )
                                
                            }
                            else {
                                List {
                                    ForEach(viewStore.studyToolList) { studyTool in
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
                    .onAppear() {
                        store.send(.fetchStudyToolUsedList)
                    }
                }
            } destination: { store in
                switch store.case {
                case let .studyTool(store):
                    StudyToolView(store: store)
                }
            }
        }
    }
}

struct StudyToolListView_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolListView(
            store: Store(
                initialState: StudyToolListDomain.State(),
                reducer: StudyToolListDomain.init
            )
        )
    }
}
