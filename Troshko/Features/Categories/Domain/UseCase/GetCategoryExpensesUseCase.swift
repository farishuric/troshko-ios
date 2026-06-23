import Foundation
import DI

protocol GetCategoryExpensesUseCase {
    func execute(categoryID: UUID) async throws -> [Expense]
}

final class StandardGetCategoryExpensesUseCase: GetCategoryExpensesUseCase {
    @Injected private var repository: CategoryRepository

    func execute(categoryID: UUID) async throws -> [Expense] {
        try await repository.fetchExpenses(categoryID: categoryID)
    }
}
