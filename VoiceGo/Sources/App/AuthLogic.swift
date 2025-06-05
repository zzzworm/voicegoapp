import ComposableArchitecture


@Reducer
struct AuthLogic {
   func reduce(into state: inout AppFeature.State, action: AppFeature.Action) -> Effect<AppFeature.Action> {
        switch action {
        case .appDelegate(.didFinishLaunching):
            enum Cancel { case stateDidChange, signOut }
            return .merge(
                .listenToNotification(notificationNames: [.signOut], mapNotificationToAction: { _ in
                        Action.digSignOut
                })
                .cancellable(id: Cancel.signOut)
            )
        
        default: return .none
        }
    }
}
