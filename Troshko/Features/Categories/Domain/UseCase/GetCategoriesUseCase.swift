import Foundation
import DI

protocol GetCategoriesUseCase {
    func execute() async throws -> [ExpenseCategory]
}

final class StandardGetCategoriesUseCase: GetCategoriesUseCase {
    @Injected private var repository: CategoryRepository

    func execute() async throws -> [ExpenseCategory] {
        try await repository.fetchCategories()
    }
}
