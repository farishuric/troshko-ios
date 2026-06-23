import Foundation
import SwiftData

/// The app-wide SwiftData container for expense data. Created once and shared via DI.
/// `ModelContainer` is `Sendable`; the `mainContext` it vends is only touched on the
/// main actor inside the repository.
enum ExpenseStore {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: ExpenseEntity.self,
                ExpenseCategoryEntity.self,
                IncomeEntryEntity.self,
                SavingsGoalEntity.self
            )
        } catch {
            fatalError("Failed to create ExpenseStore ModelContainer: \(error)")
        }
    }()
}
