import SwiftUI
import ComposableArchitecture
import Alamofire
import Pulse

@main
struct VoiceGoApp: App {
    init() {
#if DEBUG
        // 限制日志存储大小（默认 100MB）
        LoggerStore.shared.configuration.sizeLimit = 50 * 1024 * 1024 // 50MB
        
        // 自动清理过期日志（默认保留7天）
        LoggerStore.shared.configuration.saveInterval = .seconds(3600 * 24 * 3) // 3天
#endif
    }
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                RootView(
                    store: Store(
                        initialState: RootDomain.State(),
                        reducer: RootDomain.init
                    )
                )
            }
        }
    }
}
