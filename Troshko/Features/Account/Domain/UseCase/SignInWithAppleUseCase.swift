import Foundation

protocol SignInWithAppleUseCase {
    func execute(payload: SignInWithApplePayload) async throws -> AccountSession
}

struct StandardSignInWithAppleUseCase: SignInWithAppleUseCase {
    private let repository: AccountRepository

    init(repository: AccountRepository) {
        self.repository = repository
    }

    func execute(payload: SignInWithApplePayload) async throws -> AccountSession {
        try await repository.signIn(with: payload)
    }
}

