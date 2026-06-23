import Foundation

/// Domain entity for a single expense. Persistence-agnostic: the Data layer maps
/// this to/from its SwiftData `@Model` representation.
struct Expense: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var details: String
    var amount: Money
    var date: Date
    var category: ExpenseCategory?

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        amount: Money,
        date: Date,
        category: ExpenseCategory? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.amount = amount
        self.date = date
        self.category = category
    }
}
