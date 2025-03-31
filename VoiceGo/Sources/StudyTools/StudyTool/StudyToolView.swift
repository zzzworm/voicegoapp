//
//  StudyToolView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct StudyToolView: View {
    let store: StoreOf<StudyToolDomain>
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
                            retryAction: { viewStore.send(.fetchStudyHistory) }
                        )
                        
                    }
                    else {
                        ScrollView{
                            LazyVStack {
                                ToolQACardView(card: viewStore.card)
                                ForEachStore(self.store.scope(
                                    state: \.toolHistoryListState,
                                    action: StudyToolDomain.Action.toolHistory
                                )) { store in
                                    let cell = ToolHistoryCell(store: store)
                                    VStack{
                                       cell
                                       
                                    }
                                }
                            }
                        }
                    }
                }
                .task {
                    viewStore.send(.fetchStudyHistory)
                }
                .navigationTitle("StudyTool")
                .navigationViewStyle(.stack)
            }
            
        }
    }
}

struct StudyToolView_Previews: PreviewProvider {
    static var previews: some View {
        StudyToolView(
            store: Store(
                initialState: StudyToolDomain.State(id: UUID(), studyTool: StudyTool.sample[0], card: QACard(isExample: true, originText:"apply", actionText: "翻译", answer: "应用")),
                reducer: StudyToolDomain.init
            )
        )
    }
}
