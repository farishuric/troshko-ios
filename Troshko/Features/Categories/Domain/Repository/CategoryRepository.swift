import Foundation

/// Domain boundary for category management. Implemented in the Data layer
/// (`SwiftDataCategoryRepository`), backed by the same SwiftData store as Expenses
/// so categories created here are immediately visible in the expense picker.
///
/// Reuses the Expenses feature's `ExpenseCategory`/`Expense` as the canonical
/// shared domain models — categories are a concept both features own jointly.
protocol CategoryRepository {
    func fetchCategories() async throws -> [ExpenseCategory]
    func addCategory(name: String) async throws
    /// Deletes the category and all expenses associated with it.
    func deleteCategory(id: UUID) async throws
    func fetchExpenses(categoryID: UUID) async throws -> [Expense]
}
