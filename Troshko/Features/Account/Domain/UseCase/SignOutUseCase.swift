import Foundation

protocol SignOutUseCase {
    func execute() async throws
}

struct StandardSignOutUseCase: SignOutUseCase {
    private let repository: AccountRepository

    init(repository: AccountRepository) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.signOut()
    }
}

