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
            
            markdownContentView
            
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
        VStack {
            if let attributedString = store.state.attributedContent ) {
                Text(attributedString)
                    .multilineTextAlignment(.leading)
            }
            else {
                Text("无法解析的内容")
                    .foregroundColor(.red)
            }
            if let translationContent = store.state.translationContent, !translationContent.isEmpty {
                Text(translationContent)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            if let knowledgeContent = store.state.knowledgeContent, !knowledgeContent.isEmpty {
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
                store.send(.submitText(store.state.attributedContent?.string ?? ""))
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
