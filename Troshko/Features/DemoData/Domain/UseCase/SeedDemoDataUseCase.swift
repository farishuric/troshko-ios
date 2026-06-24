import Foundation

protocol SeedDemoDataUseCase {
    func execute() async throws
}

struct StandardSeedDemoDataUseCase: SeedDemoDataUseCase {
    private let repository: DemoDataRepository

    init(repository: DemoDataRepository) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.seedDemoData()
    }
}

