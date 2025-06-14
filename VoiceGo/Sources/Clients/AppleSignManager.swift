//
//  AppleSignManager.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import AuthenticationServices

public final class AppleSignInManager: NSObject {
    public static let shared = AppleSignInManager()

    private var continuation: CheckedContinuation<Result<String, Error>, Never>?

    public enum SignInError: Error, LocalizedError {
        case appleSignInFailed
        case invalidToken

        public var errorDescription: String? {
            switch self {
            case .appleSignInFailed:
                return "Apple Sign-In failed."
            case .invalidToken:
                return "Could not retrieve a valid token from Apple."
            }
        }
    }

    public func signIn() async -> Result<String, Error> {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIdToken = credential.identityToken,
                  let tokenString = String(data: appleIdToken, encoding: .utf8) else {
                continuation?.resume(returning: .failure(SignInError.invalidToken))
                return
            }
            continuation?.resume(returning: .success(tokenString))
        } else {
            continuation?.resume(returning: .failure(SignInError.appleSignInFailed))
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let authError = error as? ASAuthorizationError, authError.code == .canceled else {
            continuation?.resume(returning: .failure(error))
            return
        }
    }

}
