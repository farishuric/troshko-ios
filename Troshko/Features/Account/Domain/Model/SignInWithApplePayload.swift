import Foundation

struct SignInWithApplePayload: Equatable {
    let userIdentifier: String
    let identityToken: String?
    let authorizationCode: String?
    let email: String?
    let displayName: String?
}

