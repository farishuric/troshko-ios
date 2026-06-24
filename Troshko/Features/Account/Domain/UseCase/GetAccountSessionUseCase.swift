import Foundation

protocol GetAccountSessionUseCase {
    func execute() async -> AccountSession?
}

struct StandardGetAccountSessionUseCase: GetAccountSessionUseCase {
    private let repository: AccountRepository

    init(repository: AccountRepository) {
        self.repository = repository
    }

    func execute() async -> AccountSession? {
        await repository.currentSession()
    }
}

