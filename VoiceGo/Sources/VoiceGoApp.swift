import SwiftUI
import ComposableArchitecture
import Pulse
import PulseUI
import Alamofire

@main
struct VoiceGoApp: App {
    init() {
        // 仅在 DEBUG 模式下覆盖依赖
        // 启用 Pulse 的 URLSession 代理
        
        
#if DEBUG
        URLSessionProxyDelegate.enableAutomaticRegistration() // ✅ 关键调用
        // 步骤 1: 创建 URLSessionConfiguration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLSessionProxyDelegate.self] // ✅ 注入 Pulse 代理
        
        // 步骤 2: 创建 Alamofire Session
        let session = Session(
            configuration: configuration,
            interceptor: RetryInterceptor() // 可选：自定义拦截器
        )
        
        // 创建独立日志存储实例（避免与全局混合）
        let customLogStore = LoggerStore.shared
        // 限制日志存储大小（默认 100MB）
        LoggerStore.shared.configuration.sizeLimit = 50 * 1024 * 1024 // 50MB
        
        // 自动清理过期日志（默认保留7天）
        LoggerStore.shared.configuration.saveInterval = .seconds(3600 * 24 * 3) // 3天
#else
        let session: URLSessionProtocol = URLSession(configuration: .default)
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
