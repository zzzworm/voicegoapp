import Alamofire
import ComposableArchitecture
import Firebase
import GoogleSignIn
import Pulse
import GRDB
import SharingGRDB
import SwiftUI
import DynamicColor

@main
struct VoiceGoApp: App {

    func appDatabase() throws -> any DatabaseWriter {
        var configuration = GRDB.Configuration()
        configuration.foreignKeysEnabled = true
        #if DEBUG
            configuration.prepareDatabase { db in
                db.trace(options: .profile) {
                    print($0.expandedDescription)
                }
            }
        #endif
        @Dependency(\.context) var context
        let database: any DatabaseWriter
        if context == .live {
            let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
            database = try DatabasePool(path: path, configuration: configuration)
        } else {
            database = try DatabaseQueue(configuration: configuration)
        }
        var migrator = DatabaseMigrator()
        #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
        #endif
        migrator.registerMigration("Create UserPorfile table") { db in
            try db.create(table: UserProfile.databaseTableName) { table in
                table.primaryKey(["documentId"])
                table.column("documentId", .text).notNull()
                table.column("id", .integer).notNull()
                table.column("email", .text)
                table.column("username", .text).notNull()
                table.column("sex", .text).notNull().defaults(to: "male")
                table.column("provider", .text).notNull()
                table.column("city", .text)
                table.column("phoneNumber", .text)
                table.column("userIconUrl", .text)
                table.column("studySettingId", .text).references(UserStudySetting.databaseTableName,column: "id", onDelete: .cascade)
            }
        }
        migrator.registerMigration("Create studyTool used table") { db in
            try db.create(table: QACard.databaseTableName) { table in
                table.primaryKey(["id"])
                table.column("id", .integer).notNull()
                table.column("isExample", .boolean).defaults(to: true )
                table.column("originCaption", .text).notNull()
                table.column("originText", .text).notNull()
                table.column("actionText", .text).notNull()
                table.column("suggestions", .text)
            }
            
            try db.create(table: StudyTool.databaseTableName) { table in
                table.primaryKey(["documentId"])
                table.column("documentId", .text).notNull()
                table.column("id", .integer).notNull()
                table.column("title", .text).notNull()
                table.column("description", .text).notNull()
                table.column("categoryKey", .text).notNull()
                table.column("categoryTag", .text).notNull()
                table.column("imageUrl", .text)
                table.column("cardDocumentId", .text).references(QACard.databaseTableName,column: "id", onDelete: .cascade)
            }
            
            try db.create(table: StudyToolUsed.databaseTableName) { table in
                table.primaryKey(["documentId"])
                table.column("documentId", .text).notNull()
                table.column("id", .integer).notNull()
                table.column("lastUsedAt", .date).notNull()
                table.column("userDocumentId", .text).references(UserProfile.databaseTableName,column: "documentId", onDelete: .cascade)
                table.column("toolDocumentId", .text).references(StudyTool.databaseTableName,column: "documentId", onDelete: .cascade)
            }

            try db.create(table: UserStudySetting.databaseTableName) { table in
                table.primaryKey(["id"])
                table.column("id", .integer).notNull()
                table.column("eng_level", .text).notNull()
                table.column("word_level", .text).notNull()
                table.column("study_goal", .text).notNull()
                table.column("role", .text).notNull()
            }
        }
        try migrator.migrate(database)
        return database
    }

    init() {
        let _ = try! prepareDependencies {
            let db = try appDatabase()
            $0.defaultDatabase = db
        }
        #if DEBUG
            // 限制日志存储大小（默认 100MB）
            LoggerStore.shared.configuration.sizeLimit = 50 * 1024 * 1024  // 50MB

            // 自动清理过期日志（默认保留7天）
            LoggerStore.shared.configuration.saveInterval = .seconds(3600 * 24 * 3)  // 3天
        #endif
        
        let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#F7FAFC")]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(hexString: "#F7FAFC")]
        
    }

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        let wg = WindowGroup {
            if !_XCTIsTesting {
                AppView(store: self.appDelegate.store).enableInjection()
            }
        }
        wg
        if #available(iOS 17.0, *) {
            wg.onChange(of: scenePhase) { (phase, _) in
                self.appDelegate.store.send(.didChangeScenePhase(phase))
            }
        }
        
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#if canImport(HotSwiftUI)
@_exported import HotSwiftUI
#elseif canImport(Inject)
@_exported import Inject
#else
// This code can be found in the Swift package:
// https://github.com/johnno1962/HotSwiftUI or
// https://github.com/krzysztofzablocki/Inject

#if DEBUG
import Combine

public class InjectionObserver: ObservableObject {
    public static let shared = InjectionObserver()
    @Published var injectionNumber = 0
    var cancellable: AnyCancellable? = nil
    let publisher = PassthroughSubject<Void, Never>()
    init() {
        cancellable = NotificationCenter.default.publisher(for:
            Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))
            .sink { [weak self] change in
            self?.injectionNumber += 1
            self?.publisher.send()
        }
    }
}

extension SwiftUI.View {
    public func eraseToAnyView() -> some SwiftUI.View {
        return AnyView(self)
    }
    public func enableInjection() -> some SwiftUI.View {
        return eraseToAnyView()
    }
    public func onInjection(bumpState: @escaping () -> ()) -> some SwiftUI.View {
        return self
            .onReceive(InjectionObserver.shared.publisher, perform: bumpState)
            .eraseToAnyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct ObserveInjection: DynamicProperty {
    @ObservedObject private var iO = InjectionObserver.shared
    public init() {}
    public private(set) var wrappedValue: Int {
        get {0} set {}
    }
}
#else
extension SwiftUI.View {
    @inline(__always)
    public func eraseToAnyView() -> some SwiftUI.View { return self }
    @inline(__always)
    public func enableInjection() -> some SwiftUI.View { return self }
    @inline(__always)
    public func onInjection(bumpState: @escaping () -> ()) -> some SwiftUI.View {
        return self
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct ObserveInjection {
    public init() {}
    public private(set) var wrappedValue: Int {
        get {0} set {}
    }
}
#endif
#endif
