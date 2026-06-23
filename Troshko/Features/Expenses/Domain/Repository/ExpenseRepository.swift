import Foundation

/// Domain boundary for expense persistence. Implemented in the Data layer
/// (`SwiftDataExpenseRepository`). Keeps the dependency direction UI → Domain ← Data.
protocol ExpenseRepository {
    func fetchExpenses() async throws -> [Expense]
    func addExpense(_ expense: Expense) async throws
    func updateExpense(_ expense: Expense) async throws
    func deleteExpense(id: UUID) async throws
    func fetchCategories() async throws -> [ExpenseCategory]
}
