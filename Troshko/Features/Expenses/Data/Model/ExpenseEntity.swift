import Foundation
import SwiftData

/// SwiftData persistence model for an expense. Lives in the Data layer; the
/// repository maps it to/from the Domain `Expense` struct so the Domain stays
/// persistence-agnostic.
@Model
final class ExpenseEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String
    var amountMinor: Int
    var currencyCode: String
    var date: Date
    @Relationship var category: ExpenseCategoryEntity?

    init(
        id: UUID,
        title: String,
        details: String,
        amountMinor: Int,
        currencyCode: String,
        date: Date,
        category: ExpenseCategoryEntity? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.amountMinor = amountMinor
        self.currencyCode = currencyCode
        self.date = date
        self.category = category
    }
}

/// SwiftData persistence model for an expense category.
@Model
final class ExpenseCategoryEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .nullify, inverse: \ExpenseEntity.category)
    var expenses: [ExpenseEntity]

    init(id: UUID, name: String, createdAt: Date, expenses: [ExpenseEntity] = []) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.expenses = expenses
    }
}

// MARK: - Domain mapping

extension ExpenseEntity {
    func toDomain() -> Expense {
        Expense(
            id: id,
            title: title,
            details: details,
            amount: Money(amountMinor: amountMinor, currencyCode: currencyCode),
            date: date,
            category: category?.toDomain()
        )
    }
}

extension ExpenseCategoryEntity {
    func toDomain() -> ExpenseCategory {
        ExpenseCategory(id: id, name: name, createdAt: createdAt)
    }
}
