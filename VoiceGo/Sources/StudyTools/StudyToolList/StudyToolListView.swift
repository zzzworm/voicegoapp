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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    if viewStore.dataLoadingStatus == .loading {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    } else if viewStore.shouldShowError {
                        ErrorView(
                            message: "Oops, we couldn't fetch product list",
                            retryAction: { viewStore.send(.fetchStudyTools) }
                        )
                        
                    }
                    else {
                        List {
                            ForEachStore(self.store.scope(
                                state: \.studyToolListState,
                                action: StudyToolListDomain.Action.studyTool
                            )) { store in
                                let cell = StudyToolCell(store: store)
                                NavigationLink {
                                    StudyToolView(store:store)
                                } label: {
                                    cell
                                }
                            }
                        }
                    }
                }
                .navigationTitle("学习工具")
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear() {
            store.send(.fetchStudyTools)
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
