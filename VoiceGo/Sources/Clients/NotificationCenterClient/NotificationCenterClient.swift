import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct NotificationCenterClient {
    public var observe: @Sendable ([Notification.Name]) -> AsyncStream<Notification> = { _ in .never }
    public var post: @Sendable (Notification.Name, Any?, [AnyHashable: Any]?) -> Void
}


extension DependencyValues {
    /// Accessor for the UserCredentialsClient in the dependency values.
    var notificationCenter: NotificationCenterClient {
        get { self[NotificationCenterClient.self] }
        set { self[NotificationCenterClient.self] = newValue }
    }
}
