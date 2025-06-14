//
//  AuthenticationClient.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import Foundation
import Dependencies
import StrapiSwift

/// A structure representing the authentication response.
struct AuthenticationResponse: Equatable, Decodable {
    var jwt: String
    var user : UserProfile
}

/// An enumeration representing possible authentication errors.
enum AuthenticationError: Equatable, LocalizedError, Sendable {
    case invalidEmail
    case invalidUserPassword
    case invaildResponse

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return  String(localized: "User Identifier invalid.")
        case .invalidUserPassword:
            return String(localized: "Unknown user or invalid password.")
        case .invaildResponse:
            return String(localized: "Invaild Response")
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
                let ret = try await Strapi.authentication.local.login(
                    identifier: data.identifier,
                    password: data.password, as: UserProfile.self
                )
                
                    Strapi.configure(baseURL: Configuration.current.baseURL, token: ret.jwt)
                
                return AuthenticationResponse(jwt: ret.jwt, user: ret.user)
            }, register: { data in
                
                // Validate email
                guard data.email.isValidEmail()
                else { throw AuthenticationError.invalidEmail }

//                // Validate password
//                guard data.password.isValidPassword()
//                else { throw AuthenticationError.invalidUserPassword }
                
                // Construct parameters and perform API request
                let ret = try await Strapi.authentication.local.register(username: data.username, email: data.email, password: data.password, as: UserProfile.self)
                    Strapi.configure(baseURL: Configuration.current.baseURL, token: ret.jwt)
                
                return AuthenticationResponse(jwt: ret.jwt, user: ret.user)
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

