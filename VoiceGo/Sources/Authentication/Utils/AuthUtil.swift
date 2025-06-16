//
//  AuthUtil.swift
//  VoiceGo
//
//  Created by admin on 2025/6/3.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import SharingGRDB
import Foundation
import ComposableArchitecture
import StrapiSwift

/// 处理登录成功后的数据存储逻辑
func handleLoginResponse(
    data: AuthenticationResponse
) async {

    @Dependency(\.userKeychainClient) var userKeychainClient
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.userDefaults) var userDefaultsClient

    Log.info("loginResponse: \(data)")
    userKeychainClient.storeToken(data.jwt)
    await Strapi.configure(baseURL: Configuration.current.baseURL, token: data.jwt)
    var account = data.user
    do {
        try await database.write { db in
            try account.upsert(db)
        }
        try await userDefaultsClient.setCurrentUserID(account.documentId)
    } catch {
        Log.error("Failed to save user to database: \(error)")
    }
}
