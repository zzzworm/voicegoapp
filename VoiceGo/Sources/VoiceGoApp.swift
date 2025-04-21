import Alamofire
import ComposableArchitecture
import Firebase
import GoogleSignIn
import Pulse
import GRDB
import SharingGRDB
import SwiftUI

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
                table.column("id", .integer).notNull()
                table.column("email", .text)
                table.column("username", .text).notNull()
                table.column("provider", .text).notNull()
                table.column("phoneNumber", .text)
                table.column("userIconUrl", .text)
            }
        }
        migrator.registerMigration("Create studyTool used table") { db in
            try db.create(table: StudyTool.databaseTableName) { table in
                table.primaryKey(["documentId"])
                table.column("id", .integer).notNull()
                table.column("title", .text).notNull()
                table.column("description", .text).notNull()
                table.column("categoryKey", .text).notNull()
                table.column("imageUrl", .text)
            }
            
            try db.create(table: StudyToolUsed.databaseTableName) { table in
                table.primaryKey(["documentId"])
                table.column("id", .integer).notNull()
                table.column("lastUsedAt", .date).notNull()
                table.column("userDocumentId", .text).references(UserProfile.databaseTableName,column: "documentId", onDelete: .cascade)
                table.column("toolDocumentId", .text).references(StudyTool.databaseTableName,column: "documentId", onDelete: .cascade)
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
    }

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        let wg = WindowGroup {
            if !_XCTIsTesting {
                AppView(store: self.appDelegate.store)
            }
        }
        if #available(iOS 17.0, *) {
            wg.onChange(of: scenePhase) { (phase, _) in
                self.appDelegate.store.send(.didChangeScenePhase(phase))
            }
        }
    }
}
