import Foundation
import DI

/// Registers the MonthlyOverview feature graph into the shared `DIContainer`.
/// Called from `AppDependencies.registerAll()` at app launch. Depends on the
/// Expenses feature's `GetExpensesUseCase`, so register it after Expenses.
enum MonthlyOverviewDependencyContainer {
    static func register() {
        DIContainer.shared.register(
            StandardGetMonthlyOverviewUseCase() as GetMonthlyOverviewUseCase,
            as: GetMonthlyOverviewUseCase.self,
            configuration: .shared
        )
    }
}
