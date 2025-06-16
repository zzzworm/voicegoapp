//
//  Notification.swift
//  Shop
//
//  Created by Anatoli Petrosyants on 05.10.23.
//

import Foundation

struct NotificationItem: Equatable, Identifiable, Hashable {
    enum NotificationType: CaseIterable {
        case account, checkout
    }

    let id = UUID()
    let title: String
    let description: String
    let type: NotificationType
}

extension NotificationItem {
    static var checkout = NotificationItem(title: "Checkout",
                                       description: "You have successfully checkout products.",
                                       type: .checkout)

    static var account = NotificationItem(title: "Account",
                                      description: "Tap to add account details.",
                                      type: .account)
}
