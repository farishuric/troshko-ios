import Foundation
import DI

protocol DeleteExpenseUseCase {
    func execute(id: UUID) async throws
}

final class StandardDeleteExpenseUseCase: DeleteExpenseUseCase {
    @Injected private var repository: ExpenseRepository

    func execute(id: UUID) async throws {
        try await repository.deleteExpense(id: id)
    }
}
