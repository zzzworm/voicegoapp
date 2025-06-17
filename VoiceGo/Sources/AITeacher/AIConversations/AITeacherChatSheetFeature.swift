import ComposableArchitecture
import Foundation

@Reducer
struct AITeacherChatSheetFeature {
    @ObservableState
    struct State: Equatable {
        var title: String = "AI Teacher"
        //swiftlint:disable:next all
        var markdownContent: String = ""
    }

    enum Action {
        case configButtonTapped
        case toolbarButtonTapped(String)
        case bottomButtonTapped
        case closeButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .configButtonTapped:
                // Handle config button tap
                return .none

            case let .toolbarButtonTapped(buttonID):
                // Handle toolbar button tap
                print("Toolbar button \(buttonID) tapped")
                return .none

            case .bottomButtonTapped:
                // Handle bottom button tap
                return .none
                
            case .closeButtonTapped:
                // Logic to close the sheet, usually handled by the parent
                return .none
            }
        }
    }
}
