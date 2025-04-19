//
//  Live.swift
//
//
//  Created ErrorErrorError on 4/6/23.
//  Copyright © 2023. All rights reserved.
//

import Dependencies
import Foundation

// MARK: - UserDefaultsClient + DependencyKey

extension UserDefaultsClient: DependencyKey {
    public static let liveValue : Self = {
        let defaults: () -> UserDefaults = { UserDefaults(suiteName: "group.com.souler")! }
        return Self(
            doubleForKey: { defaults().double(forKey: $0) },
            intForKey: { defaults().integer(forKey: $0) },
            boolForKey: { defaults().bool(forKey: $0) },
            dataForKey: { defaults().data(forKey: $0) },
            setDouble: { defaults().setValue($0, forKey: $1) },
            setInt: { defaults().setValue($0, forUndefinedKey: $1) },
            setBool: { defaults().setValue($0, forKey: $1) },
            setData: { defaults().setValue($0, forUndefinedKey: $1) },
            stringForKey: { defaults().string(forKey: $0) },
            setString: { defaults().set($0, forKey: $1) },
            remove: { defaults().removeObject(forKey: $0) }
        )
    }()
}

// MARK: - UserDefaults + Sendable

extension UserDefaults: @unchecked Sendable {}
