//
//  Client.swift
//
//
//  Created ErrorErrorError on 4/6/23.
//  Copyright © 2023. All rights reserved.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

// MARK: - UserDefaultsClient

public struct UserDefaultsClient: Sendable {
  var doubleForKey: @Sendable (String) -> Double
  var intForKey: @Sendable (String) -> Int
  var boolForKey: @Sendable (String) -> Bool
  var dataForKey: @Sendable (String) -> Data?

  var setDouble: @Sendable (Double, String) async -> Void
  var setInt: @Sendable (Int, String) async -> Void
  var setBool: @Sendable (Bool, String) async -> Void
  var setData: @Sendable (Data?, String) async -> Void

 var stringForKey: @Sendable (String) -> String?
    /// A method to set a string value for a given key.
    var setString: @Sendable (String, String) async -> Void

  var remove: @Sendable (String) async -> Void

  /// A computed property indicating if the first launch onboarding has been shown.
    var hasShownFirstLaunchOnboarding: Bool {
        self.boolForKey(Self.hasShownFirstLaunchOnboardingKey)
    }
    
    /// A method to set the value indicating if the first launch onboarding has been shown.
    func setHasShownFirstLaunchOnboarding(_ bool: Bool) async {
        await self.setBool(bool, Self.hasShownFirstLaunchOnboardingKey)
    }
    
    /// A computed property for retrieving the stored token.
    var token: String? {
        self.stringForKey(Self.token)
    }
    
    /// A method to set the stored token.
    func setToken(_ string: String) async {
        await self.setString(string, Self.token)
    }
}

private extension UserDefaultsClient {
    static let hasShownFirstLaunchOnboardingKey = "hasShownFirstLaunchOnboardingKey"
    static let token = "token"
}

// MARK: TestDependencyKey

extension UserDefaultsClient: TestDependencyKey {
    public static let testValue : Self = {
        let defaults: () -> UserDefaults = { UserDefaults(suiteName: "group.com.souler")! }
        return Self(
            doubleForKey: unimplemented("\(Self.self).doubleForKey is unimplemented."),
            intForKey: unimplemented("\(Self.self).intForKey is unimplemented."),
            boolForKey: unimplemented("\(Self.self).boolForKey is unimplemented."),
            dataForKey: unimplemented("\(Self.self).dataForKey is unimplemented."),
            setDouble: unimplemented("\(Self.self).setDouble is unimplemented."),
            setInt: unimplemented("\(Self.self).setInt is unimplemented."),
            setBool: unimplemented("\(Self.self).setBool is unimplemented."),
            setData: unimplemented("\(Self.self).setData is unimplemented."),
            stringForKey: { defaults().string(forKey: $0) },
            setString: { defaults().set($0, forKey: $1) },
            remove: { defaults().set(nil, forKey: $0) }
        )
    }()
}

extension DependencyValues {
  public var userDefaults: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
