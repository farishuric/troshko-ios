import Foundation
import DI

/// Registers the Expenses feature graph into the shared `DIContainer`.
/// Called from `AppDependencies.registerAll()` at app launch.
enum ExpensesDependencyContainer {
    static func register() {
        let repository = SwiftDataExpenseRepository(container: ExpenseStore.container)
        DIContainer.shared.register(
            repository as ExpenseRepository,
            as: ExpenseRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetExpensesUseCase() as GetExpensesUseCase,
            as: GetExpensesUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardAddExpenseUseCase() as AddExpenseUseCase,
            as: AddExpenseUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardUpdateExpenseUseCase() as UpdateExpenseUseCase,
            as: UpdateExpenseUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardDeleteExpenseUseCase() as DeleteExpenseUseCase,
            as: DeleteExpenseUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetExpenseCategoriesUseCase() as GetExpenseCategoriesUseCase,
            as: GetExpenseCategoriesUseCase.self,
            configuration: .shared
        )
    }
}
