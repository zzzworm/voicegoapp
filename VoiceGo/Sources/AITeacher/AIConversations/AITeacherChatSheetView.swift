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
        ScrollView {
            Markdown(store.markdownContent)
                .markdownTheme(.gitHub)
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    private var toolbarView: some View {
        HStack(spacing: 20) {
            Button("Option 1") { store.send(.toolbarButtonTapped("1")) }
                .buttonStyle(.bordered)
            
            Button("Option 2") { store.send(.toolbarButtonTapped("2")) }
                .buttonStyle(.bordered)
            
            Button("Option 3") { store.send(.toolbarButtonTapped("3")) }
                .buttonStyle(.bordered)
        }
        .padding(.vertical, 15)
    }

    private var bottomButtonView: some View {
        Button(action: {
            store.send(.bottomButtonTapped)
        }) {
            Text("Continue")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.top, 5)
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
