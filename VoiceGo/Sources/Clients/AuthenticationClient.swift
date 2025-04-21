//
//  AuthenticationClient.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import Foundation
import Dependencies

/// A structure representing the authentication response.
struct AuthenticationResponse: Equatable, Decodable {
    var jwt: String
    var user : UserProfile
}

/// An enumeration representing possible authentication errors.
enum AuthenticationError: Equatable, LocalizedError, Sendable {
    case invalidEmail
    case invalidUserPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return  "User Identifier invalid."
        case .invalidUserPassword:
            return "Unknown user or invalid password."
        }
    }
}

/// A client for handling authentication operations.
struct AuthenticationClient {
    /// A method for performing login using the provided credentials.
    var login: @Sendable (LoginEmailRequest) async throws -> AuthenticationResponse
    var register: @Sendable (RegisterEmailRequest) async throws -> AuthenticationResponse
}

extension DependencyValues {
    /// Accessor for the AuthenticationClient in the dependency values.
    var authenticationClient: AuthenticationClient {
        get { self[AuthenticationClient.self] }
        set { self[AuthenticationClient.self] = newValue }
    }
}

extension AuthenticationClient: DependencyKey {
    /// A live implementation of AuthenticationClient.
    static let liveValue: Self = {
        return Self(
            login: { data in
    
                // Construct parameters and perform API request
                return try await VoiceGoAPIClient.provider.async.request(.loginLocal(data))
                    .map(AuthenticationResponse.self)
            }, register: { data in
                
                // Validate email
                guard data.email.isValidEmail()
                else { throw AuthenticationError.invalidEmail }

//                // Validate password
//                guard data.password.isValidPassword()
//                else { throw AuthenticationError.invalidUserPassword }
                
                // Construct parameters and perform API request
                return try await VoiceGoAPIClient.provider.async.request(.registerLocal(data))
                    .map(AuthenticationResponse.self)
            }
        )
    }()
}

extension AuthenticationClient: TestDependencyKey {
    static let testValue = Self(
        login: unimplemented("\(Self.self).login"),
        register: unimplemented("\(Self.self).register")
    )
}

