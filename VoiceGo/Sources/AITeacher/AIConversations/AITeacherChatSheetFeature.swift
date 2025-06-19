import ComposableArchitecture
import Foundation
import Dependencies

@Reducer
struct AITeacherChatSheetFeature {
    
    @Dependency(\.aiToolsClient) var aiToolsClient
    
    @ObservableState
    struct State: Equatable {
        var title: String = "AI Teacher"
        //swiftlint:disable:next all
        var markdownContent: String = "" {
            didSet {
                if let attributedString = try? AttributedString(markdown: markdownContent,
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
        init( title: String = "AI Teacher", markdownContent: String = "") {
            self.title = title
            self.markdownContent = markdownContent
        }
    }

    enum Action {
        case configButtonTapped
        case translationButtonTapped
        case knowledgeButtonTapped
        case translationContentChanged(String)
        case knowledgeContentChanged(String)
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

            case .translationButtonTapped:
                // Handle toolbar button tap
                if let attributedContentCharacters = state.attributedContent?.characters {
                    return .run { send in
                        // Call the AI translation service
                        do {
                            // Assuming aiToolsClient has a translate method
                            let toTrasnlate =  String(attributedContentCharacters)
                            let result = try await aiToolsClient.translate(toTrasnlate)
                            await send(.translationContentChanged(result))
                        } catch {
                            print("Translation error: \(error)")
                        }
                    }
                }
                else{
                    return .none
                }
            case .knowledgeButtonTapped:
                // Handle toolbar button tap
                return .none
            
            case .translationContentChanged(let content):
                state.translationContent = content
                return .none
            case .knowledgeContentChanged(let content):
                state.knowledgeContent = content
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
