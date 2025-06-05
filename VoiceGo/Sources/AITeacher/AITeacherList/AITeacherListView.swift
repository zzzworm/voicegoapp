import SwiftUI
import ComposableArchitecture



struct AITeacherListView: View {
    @Perception.Bindable var store: StoreOf<AITeacherListFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    
                    // Main content area
                    if store.dataLoadingStatus == .loading && store.aiTeacherList.isEmpty {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if store.shouldShowError {
                        Spacer()
                        ErrorView(
                            message: "Could not load AI Teachers. Please try again.", // Replace with localized string
                            retryAction: { store.send(.fetchAITeachers) }
                        )
                        Spacer()
                    } else if store.aiTeacherList.isEmpty && store.dataLoadingStatus == .success {
                        Spacer()
                        Text("No AI Teachers found in this category.") // Replace with localized string
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(store.aiTeacherList) { aiTeacher in
                                    AITeacherCell(aiTeacher: aiTeacher)
                                        .onTapGesture {
                                            store.send(.view(.onAITeacherTap(aiTeacher)))
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 5) // Add a little space from category buttons
                        }
                    }
                }
                .commonBackground() // Assuming you have a commonBackground modifier
                .navigationTitle("AI Teachers") // Replace with localized string
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if store.aiTeacherList.isEmpty && store.dataLoadingStatus == .notStarted {
                        store.send(.fetchAITeachers)
                    }
                }
            } destination: { store in
                // This handles navigation to the detail view
                switch store.case {
                case let .aiTeacher(detailStore):
                    AITeacherPageView(store: detailStore) // Using the placeholder detail view
                }
            }
        }
        .enableInjection() // Assuming you use Inject for previews and testing
    }

#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

// Preview
struct AITeacherListView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample data for preview
        let sampleTeachers = [
            AITeacher(id: 1,
                      documentId: "t1",
                      name: "Dr. Emily Carter",
                      introduce: "Focuses on business English.",
                      createdAt: Date(),
                      updatedAt: Date(),
                      publishedAt: Date(),
                      sex: "female",
                      difficultyLevel: 2,
                      tags: "business",
                      card: nil,
                      cardId: nil),
            AITeacher(id: 2,
                      documentId: "t2",
                      name: "Mr. John Doe",
                      introduce: "Specializes in travel vocabulary.",
                      createdAt: Date(),
                      updatedAt: Date(),
                      publishedAt: Date(),
                      sex: "male",
                      difficultyLevel: 1,
                      tags: "travel",
                      card: nil,
                      cardId: nil)
        ]

        let store = Store(
            initialState: AITeacherListFeature.State(
                dataLoadingStatus: .success,
                aiTeacherList: IdentifiedArrayOf(uniqueElements: sampleTeachers)
            ),
            reducer: AITeacherListFeature.init
        )
        
        // Mocking API client for preview if needed for fetch actions
        // store.dependencies.apiClient = .previewValue ...

        return NavigationView {
            AITeacherListView(store: store)
        }
    }
}

