import Foundation
import DI

protocol UpdateExpenseUseCase {
    func execute(_ expense: Expense) async throws
}

final class StandardUpdateExpenseUseCase: UpdateExpenseUseCase {
    @Injected private var repository: ExpenseRepository

    func execute(_ expense: Expense) async throws {
        try await repository.updateExpense(expense)
    }
}
