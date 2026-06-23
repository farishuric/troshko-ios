import Foundation
import SwiftData

/// SwiftData-backed `CategoryRepository`. Operates on the **shared** `ExpenseStore`
/// container and the Expenses feature's `ExpenseCategoryEntity` / `ExpenseEntity`, so
/// categories managed here and expenses created in the Expenses feature stay unified
/// (one store, one set of category rows). All access hops to the main actor (SwiftData's
/// `mainContext` is main-actor bound); results cross back out as Sendable Domain structs.
final class SwiftDataCategoryRepository: CategoryRepository {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetchCategories() async throws -> [ExpenseCategory] {
        let container = container
        return try await MainActor.run {
            let descriptor = FetchDescriptor<ExpenseCategoryEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try container.mainContext.fetch(descriptor).map { $0.toDomain() }
        }
    }

    func addCategory(name: String) async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            let entity = ExpenseCategoryEntity(id: UUID(), name: name, createdAt: Date())
            context.insert(entity)
            try context.save()
        }
    }

    func deleteCategory(id: UUID) async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            var descriptor = FetchDescriptor<ExpenseCategoryEntity>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            guard let entity = try context.fetch(descriptor).first else { return }
            // Match the legacy behaviour: deleting a category removes its expenses too.
            for expense in entity.expenses {
                context.delete(expense)
            }
            context.delete(entity)
            try context.save()
        }
    }

    func fetchExpenses(categoryID: UUID) async throws -> [Expense] {
        let container = container
        return try await MainActor.run {
            var descriptor = FetchDescriptor<ExpenseCategoryEntity>(predicate: #Predicate { $0.id == categoryID })
            descriptor.fetchLimit = 1
            guard let category = try container.mainContext.fetch(descriptor).first else { return [] }
            return category.expenses
                .sorted { $0.date > $1.date }
                .map { $0.toDomain() }
        }
    }
}
