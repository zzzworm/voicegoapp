//
//  AppleSignInClient.swift
//  VoiceGo
//
//  Created by Cascade on 6/14/25.
//

import Foundation
import Dependencies
import StrapiSwift


struct AppleSignInClient {
    var login: () async throws -> AuthenticationResponse
    var logout: () -> Void
}

extension DependencyValues {
    var appleSignInClient: AppleSignInClient {
        get { self[AppleSignInClient.self] }
        set { self[AppleSignInClient.self] = newValue }
    }
}

extension AppleSignInClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            login: {
                
                let result = await AppleSignInManager.shared.signIn()
                let token: String

                switch result {
                case .success(let identityToken):
                    token = identityToken
                case .failure(let error):
                    throw error
                }

                // NOTE: Strapi's Apple provider might expect 'id_token' instead of 'access_token'.
                // Using 'access_token' to match the Google client's parameter name.
                // This may need adjustment based on your backend implementation.
                let authResponse: ConnectAuth.AuthResponse<UserProfile> = try await Strapi.authentication.connect.auth(provider: "apple", access_token: token, as: UserProfile.self)
                return AuthenticationResponse(jwt: authResponse.jwt, user: authResponse.user)
            },
            logout: {
                // No-op for Apple Sign In, as session logout is handled server-side.
            }
        )
    }()
}

extension AppleSignInClient: TestDependencyKey {
    static let testValue = Self(
        login: unimplemented("\(Self.self).login"),
        logout: unimplemented("\(Self.self).logout")
    )
}
