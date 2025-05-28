import SwiftUI

struct CommonBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
    }
}

extension View {
    func commonBackground() -> some View {
        modifier(CommonBackgroundModifier())
    }
} 