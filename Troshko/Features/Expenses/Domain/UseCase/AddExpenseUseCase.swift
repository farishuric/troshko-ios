import Foundation
import DI

protocol AddExpenseUseCase {
    func execute(_ expense: Expense) async throws
}

final class StandardAddExpenseUseCase: AddExpenseUseCase {
    @Injected private var repository: ExpenseRepository

    func execute(_ expense: Expense) async throws {
        try await repository.addExpense(expense)
    }
}
