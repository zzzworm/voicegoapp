import Foundation
import ComposableArchitecture
import StrapiSwift // Assuming StrapiSwift is used for API responses


@Reducer
struct AITeacherListFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.defaultDatabase) var database // Assuming GRDB is used via this dependency

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var aiTeacherList: IdentifiedArrayOf<AITeacher> = []

        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
    }

    enum Action {
        enum ViewAction: Equatable {
            case onAITeacherTap(AITeacher)
            // case onAppear // If needed to load initial data
        }
        case view(ViewAction)
        case fetchAITeachers
        case fetchAITeachersResponse(TaskResult<StrapiResponse<[AITeacher]>>) // Assuming StrapiResponse
        case path(StackActionOf<Path>)
    }

    @Reducer(state: .equatable)
    enum Path {
        // This will be the destination when an AI Teacher is tapped.
        // Assuming you'll have an AITeacherFeature for the detail view.
        case aiTeacher(AITeacherPageFeature)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchAITeachers:
                if state.dataLoadingStatus == .loading {
                    return .none // Avoid re-fetching if already loading
                }
                
                state.dataLoadingStatus = .loading
                return .run { send in
                    do {
                        // IMPORTANT: Replace "fetchAITeachers" with the actual API client method
                        // The categoryTag.rawValue might be used if your API expects a string.
                        let result = try await apiClient.fetchAITeachers()
                        await send(.fetchAITeachersResponse(.success(result)))
                    } catch {
                        await send(.fetchAITeachersResponse(.failure(error)))
                    }
                }

            case .fetchAITeachersResponse(.success(let aiTeacherListRsp)):
                var fetchedTeachers: [AITeacher] = []
                MainActor.assumeIsolated { // Ensure UI updates are on the main actor
                    fetchedTeachers = aiTeacherListRsp.data
                }
                state.dataLoadingStatus = .success
                state.aiTeacherList = IdentifiedArrayOf(uniqueElements: fetchedTeachers)

                // Save to database (similar to StudyToolsFeature)
                return .run { [fetchedTeachers] _ in // Capture list to avoid issues with state changes
                    do {
                        try await self.database.write { db in
                            for var teacher in fetchedTeachers { // Make mutable to handle potential GRDB requirements
                                try teacher.upsert(db) // Assuming AITeacher conforms to GRDB's PersistableRecord
                            }
                        }
                    } catch {
                        // Handle or log database save error
                        print("Error saving AI Teachers to database: \(error)")
                    }
                }

            case .fetchAITeachersResponse(.failure(let error)):
                state.dataLoadingStatus = .error
                // Log or handle error appropriately
                print("Error fetching AI Teachers: \(error)")
                return .none

            case .view(let viewAction):
                switch viewAction {
                case .onAITeacherTap(let aiTeacher):
                    // Navigate to the detail view for the selected AI Teacher
                    // This assumes AITeacherFeature.State can be initialized with an AITeacher
                   state.path.append(.aiTeacher(.init(aiTeacher: aiTeacher)))
                    return .none
                // case .onAppear:
                //    if state.aiTeacherList.isEmpty && state.dataLoadingStatus == .notStarted {
                //        return .send(.fetchAITeachers(state.currentCategory))
                //    }
                //    return .none
                }
            
            case .path:
                // Handle navigation path actions if needed, or rely on .forEach
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
