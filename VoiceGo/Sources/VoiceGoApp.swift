import SwiftUI
import ComposableArchitecture
import Alamofire
import Pulse
import Firebase
import GoogleSignIn

@main
struct VoiceGoApp: App {
    
    private func setupAppearance() {
        // Set up any global UI appearance settings
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Use the accent color for the navigation bar title
        let orangeColor = UIColor(named: "Orange")
        appearance.titleTextAttributes = [.foregroundColor: orangeColor ?? .systemOrange]
        appearance.largeTitleTextAttributes = [.foregroundColor: orangeColor ?? .systemOrange]
        
        // Apply the appearance settings
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Additional setup if needed
        setupAppearance()
#if DEBUG
        // 限制日志存储大小（默认 100MB）
        LoggerStore.shared.configuration.sizeLimit = 50 * 1024 * 1024 // 50MB
        
        // 自动清理过期日志（默认保留7天）
        LoggerStore.shared.configuration.saveInterval = .seconds(3600 * 24 * 3) // 3天
#endif
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
        @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        let wg = WindowGroup {
            if !_XCTIsTesting {
                AppView(
                    store: Store(
                        initialState: AppFeature.State(),
                        reducer: AppFeature.init
                    )
                )
            }
        }
        if #available(iOS 17.0, *) {
            wg.onChange(of: scenePhase) { (phase, _) in
                self.appDelegate.store.send(.didChangeScenePhase(phase))
            }
        }
    }
}
