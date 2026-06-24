import Foundation

final class UserDefaultsAccountRepository: AccountRepository {
    private let defaults: UserDefaults
    private let sessionKey = "troshko.account.session"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func currentSession() async -> AccountSession? {
        guard let data = defaults.data(forKey: sessionKey) else { return nil }
        return try? JSONDecoder().decode(AccountSession.self, from: data)
    }

    func signIn(with payload: SignInWithApplePayload) async throws -> AccountSession {
        let session = AccountSession(
            userIdentifier: payload.userIdentifier,
            displayName: payload.displayName,
            email: payload.email,
            signedInAt: Date()
        )
        let data = try JSONEncoder().encode(session)
        defaults.set(data, forKey: sessionKey)
        return session
    }

    func signOut() async throws {
        defaults.removeObject(forKey: sessionKey)
    }

    func deleteAccount() async throws {
        defaults.removeObject(forKey: sessionKey)
    }
}

