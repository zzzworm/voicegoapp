import SwiftUI
import ComposableArchitecture


@main
struct VoiceGoApp: App {
    init() {
        // 仅在 DEBUG 模式下覆盖依赖
      }
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
