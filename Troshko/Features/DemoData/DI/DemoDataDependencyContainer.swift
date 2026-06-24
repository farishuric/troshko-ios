import DI
import Foundation

enum DemoDataDependencyContainer {
    static func register() {
        let repository = SwiftDataDemoDataRepository(container: ExpenseStore.container) as DemoDataRepository

        DIContainer.shared.register(
            repository,
            as: DemoDataRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardSeedDemoDataUseCase(repository: repository) as SeedDemoDataUseCase,
            as: SeedDemoDataUseCase.self,
            configuration: .shared
        )
    }
}

