import Foundation
import DI

protocol GetExpenseCategoriesUseCase {
    func execute() async throws -> [ExpenseCategory]
}

final class StandardGetExpenseCategoriesUseCase: GetExpenseCategoriesUseCase {
    @Injected private var repository: ExpenseRepository

    func execute() async throws -> [ExpenseCategory] {
        try await repository.fetchCategories()
    }
}
