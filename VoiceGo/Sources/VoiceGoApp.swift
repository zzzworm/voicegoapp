import SwiftUI
import ComposableArchitecture


@main
struct VoiceGoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: RootDomain.State(),
                    reducer: RootDomain.init
                )
            )
        }
    }
}
