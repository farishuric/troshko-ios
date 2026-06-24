import Foundation

protocol DeleteAccountUseCase {
    func execute() async throws
}

struct StandardDeleteAccountUseCase: DeleteAccountUseCase {
    private let repository: AccountRepository

    init(repository: AccountRepository) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.deleteAccount()
    }
}

