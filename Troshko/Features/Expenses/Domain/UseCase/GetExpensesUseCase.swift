import Foundation
import DI

protocol GetExpensesUseCase {
    func execute() async throws -> [Expense]
}

final class StandardGetExpensesUseCase: GetExpensesUseCase {
    @Injected private var repository: ExpenseRepository

    func execute() async throws -> [Expense] {
        try await repository.fetchExpenses()
    }
}
