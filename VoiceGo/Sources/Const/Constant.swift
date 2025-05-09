//
//  Constant.swift
//  VoiceGo
//
//  Created by admin on 2025/5/9.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//
import Foundation


public enum NotificationNames {
        static let signOutNotificationName = "com.zzzwormstudio.voicego.signOut"
}

extension Notification.Name {
    public static var signOut: Notification.Name {
        Notification.Name(NotificationNames.signOutNotificationName)
    }
}
