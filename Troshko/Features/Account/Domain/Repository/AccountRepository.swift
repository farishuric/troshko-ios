import Foundation

protocol AccountRepository {
    func currentSession() async -> AccountSession?
    func signIn(with payload: SignInWithApplePayload) async throws -> AccountSession
    func signOut() async throws
    func deleteAccount() async throws
}

