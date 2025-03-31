//
//  APIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import Alamofire

struct APIClient {
    var fetchStudyTools:  @Sendable () async throws -> [StudyTool]
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    
    struct Failure: Error, Equatable {}
}

// This is the "live" fact dependency that reaches into the outside world to fetch the data from network.
// Typically this live implementation of the dependency would live in its own module so that the
// main feature doesn't need to compile it.
extension APIClient: DependencyKey {
  static let liveValue = Self(
    fetchStudyTools: {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://fakestoreapi.com/products")!)
        let products = try JSONDecoder().decode([StudyTool].self, from: data)
        return products
    },
    fetchUserProfile: {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://fakestoreapi.com/users/1")!)
        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
        return profile
    }
  )
}

extension APIClient {
    static var previewValue = Self(
        fetchStudyTools: { StudyTool.sample },
        fetchUserProfile: { .sample }
    )
}

extension APIClient {
    static var testValue = Self(
        fetchStudyTools: { StudyTool.sample },
        fetchUserProfile: { .sample }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
