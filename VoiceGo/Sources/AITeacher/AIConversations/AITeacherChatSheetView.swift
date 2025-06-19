import ComposableArchitecture
import SwiftUI
import MarkdownUI


struct AITeacherChatSheetView: View {
#if DEBUG
    @ObserveInjection var forceRedraw
#endif

    let store: StoreOf<AITeacherChatSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            markdownContentView.padding(.vertical,5)
            
            toolbarView
            
            bottomButtonView
        }
        .padding()
        .background(Color(.systemBackground))
        .enableInjection()
    }

    private var headerView: some View {
        HStack {
            Text(store.title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                store.send(.configButtonTapped)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
            }
        }
        .padding(.bottom, 10)
    }

    private var markdownContentView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let attributedString = store.state.attributedContent  {
                Text(attributedString)
                    .multilineTextAlignment(.leading)
            }
            else {
                Text("无法解析的内容")
                    .foregroundColor(.red)
            }
            if let translationContent = store.state.translationContent, !translationContent.isEmpty {
                Divider()
                Text(translationContent)
                    .foregroundColor(.secondary)
            }
            if let knowledgeContent = store.state.knowledgeContent, !knowledgeContent.isEmpty {
                Divider()
                Text(knowledgeContent)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
        }
    }

    private var toolbarView: some View {
        HStack(spacing: 10) {
            Button("翻") { store.send(.translationButtonTapped) }
                .buttonStyle(.bordered)
            
            Button("AI") { store.send(.knowledgeButtonTapped) }
                .buttonStyle(.bordered)
            Spacer()
            
            Button("发送") {
                if let attributedContentCharacters  = store.state.attributedContent?.characters {
                    let text =  String(attributedContentCharacters)
                    store.send(.submitText(text))
                }
                
            }
                .buttonStyle(.bordered)
        }
        .padding(.bottom, 5)
    }

    private var bottomButtonView: some View {
        SpeechRecognitionInputView(store: store.scope(state: \.speechRecognitionInputState, action: \.speechRecognitionInput))
            .frame(maxHeight: 30)
    }
}

#Preview {
    AITeacherChatSheetView(
        store: Store(
            initialState: AITeacherChatSheetFeature.State(),
            reducer: { AITeacherChatSheetFeature() }
        )
    )
}
