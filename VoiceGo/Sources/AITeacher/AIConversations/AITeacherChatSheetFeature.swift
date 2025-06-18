import ComposableArchitecture
import Foundation

@Reducer
struct AITeacherChatSheetFeature {
    @ObservableState
    struct State: Equatable {
        var title: String = "AI Teacher"
        //swiftlint:disable:next all
        var markdownContent: String = "" {
            didSet {
                if let attributedString = try? AttributedString(markdown: store.state.markdownContent,
                                                                options: .init(interpretedSyntax: .
                                                                               inlineOnlyPreservingWhitespace,
                                                                               failurePolicy: .returnPartiallyParsedIfPossible)) {
                    self.attributedContent = attributedString
                }
            }
        }
        var attributedContent: AttributedString?
        var translationContent : String?
        var knowledgeContent: String?
        var inputText : String = ""
        var speechRecognitionInputState: SpeechRecognitionInputDomain.State = .init()
    }

    enum Action {
        case configButtonTapped
        case translationButtonTapped
        case knowledgeButtonTapped
        case submitText(String)
        case closeButtonTapped
        case speechRecognitionInput(SpeechRecognitionInputDomain.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.speechRecognitionInputState, action: \.speechRecognitionInput) {
            SpeechRecognitionInputDomain()
        }
        Reduce { state, action in
            switch action {
            case .configButtonTapped:
                // Handle config button tap
                return .none

            case let .translationButtonTapped:
                // Handle toolbar button tap
                return .none
            case let .knowledgeButtonTapped:
                // Handle toolbar button tap
                return .none
                
            case .closeButtonTapped:
                // Logic to close the sheet, usually handled by the parent
                return .none
            case .speechRecognitionInput(let action):
                switch action {
                case .binding:
                    break
                case .alert, .recordButtonTapped, .recordButtonReleased:
                    break
                case .speech(let result):
                    switch result {
                    case .success(let text):
                        state.inputText = text
                        return .send(.submitText(text))
                    case .failure(let error):
                        print("Error transcribing speech: \(error)")
                    }

                case .speechRecognizerAuthorizationStatusResponse:
                    break
                case .soundLeveUpdate:
                    return .none
                }
                return .none
            case .submitText(_):
                return .none
            }
            
        }
    }
}
