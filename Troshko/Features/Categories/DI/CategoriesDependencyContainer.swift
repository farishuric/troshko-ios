import Foundation
import DI

/// Registers the Categories feature graph into the shared `DIContainer`.
/// Called from `AppDependencies.registerAll()` at app launch. Shares the
/// Expenses `ExpenseStore.container` so categories live in one unified store.
enum CategoriesDependencyContainer {
    static func register() {
        let repository = SwiftDataCategoryRepository(container: ExpenseStore.container)
        DIContainer.shared.register(
            repository as CategoryRepository,
            as: CategoryRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetCategoriesUseCase() as GetCategoriesUseCase,
            as: GetCategoriesUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardAddCategoryUseCase() as AddCategoryUseCase,
            as: AddCategoryUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardDeleteCategoryUseCase() as DeleteCategoryUseCase,
            as: DeleteCategoryUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetCategoryExpensesUseCase() as GetCategoryExpensesUseCase,
            as: GetCategoryExpensesUseCase.self,
            configuration: .shared
        )
    }
}
