import DI
import Foundation

enum HomeDependencyContainer {
    static func register() {
        DIContainer.shared.register(
            SwiftDataIncomeRepository(container: ExpenseStore.container) as IncomeRepository,
            as: IncomeRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            SwiftDataSavingsGoalRepository(container: ExpenseStore.container) as SavingsGoalRepository,
            as: SavingsGoalRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardFetchIncomeEntriesUseCase() as FetchIncomeEntriesUseCase,
            as: FetchIncomeEntriesUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardAddIncomeEntryUseCase() as AddIncomeEntryUseCase,
            as: AddIncomeEntryUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardFetchSavingsGoalUseCase() as FetchSavingsGoalUseCase,
            as: FetchSavingsGoalUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardUpsertSavingsGoalUseCase() as UpsertSavingsGoalUseCase,
            as: UpsertSavingsGoalUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetHomeSummaryUseCase() as GetHomeSummaryUseCase,
            as: GetHomeSummaryUseCase.self,
            configuration: .shared
        )
    }
}
