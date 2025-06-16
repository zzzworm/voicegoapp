//
//  GoogleSignInClient.swift
//  Shop
//
//  Created by Anatoli Petrosyants on 07.10.24.
//

import Foundation
import Dependencies
import UIKit
import GoogleSignIn
import StrapiSwift

/// A client for handling authentication operations.
struct GoogleSignInClient {
    /// A method for performing login using the provided credentials.
    var login: (UIViewController) async throws -> AuthenticationResponse
    var logout: () -> Void
}

extension DependencyValues {
    /// Accessor for the GoogleSignInClient in the dependency values.
    var googleSignInClient: GoogleSignInClient {
        get { self[GoogleSignInClient.self] }
        set { self[GoogleSignInClient.self] = newValue }
    }
}

extension GoogleSignInClient: DependencyKey {
    /// A live implementation of GoogleSignInClient.

    static let liveValue: Self = {
        return Self(
            login: { rootViewController in
//                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
//                    guard let result = signInResult else {
//                        Log.debug("GIDSignIn error \(error?.localizedDescription)")
//                        return
//                    }
//
//                    // If sign in succeeded, display the app's main content View.
//                    Log.debug("GIDSignIn signInResult \(signInResult)")
//                }

                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

                let user = result.user
                let accessToken = user.accessToken
                let ret =  try await Strapi.authentication.connect.auth(provider: "google", access_token: accessToken.tokenString, as: UserProfile.self)
                return AuthenticationResponse(jwt: ret.jwt, user: ret.user)

            },
            logout: {
                GIDSignIn.sharedInstance.signOut()
            }
        )
    }()
}

extension GoogleSignInClient: TestDependencyKey {
    static let testValue = Self(
        login: unimplemented("\(Self.self).login"),
        logout: unimplemented("\(Self.self).logout")
    )
}
