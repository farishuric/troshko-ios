import Foundation

/// Domain entity for an expense category. During the migration the full Categories
/// management feature still lives on Core Data (Phase 2); the Expenses feature reads
/// categories from its own SwiftData store for selection only.
struct ExpenseCategory: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}
