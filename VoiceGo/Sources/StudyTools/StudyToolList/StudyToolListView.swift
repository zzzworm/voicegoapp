//
//  StudyToolListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolListView: View {
    let store: StoreOf<StudyToolListDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    if viewStore.isLoading {
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
                .task {
                    viewStore.send(.fetchStudyTools)
                }
                .navigationTitle("StudyTools")
                .navigationViewStyle(.stack)
                
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
