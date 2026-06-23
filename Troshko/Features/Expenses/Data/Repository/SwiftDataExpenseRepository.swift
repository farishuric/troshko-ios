import Foundation
import SwiftData

/// SwiftData-backed `ExpenseRepository`. All store access hops to the main actor
/// (SwiftData's `mainContext` is main-actor bound); results are plain Sendable
/// Domain structs, so they cross back out safely.
final class SwiftDataExpenseRepository: ExpenseRepository {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetchExpenses() async throws -> [Expense] {
        let container = container
        return try await MainActor.run {
            let descriptor = FetchDescriptor<ExpenseEntity>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try container.mainContext.fetch(descriptor).map { $0.toDomain() }
        }
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

    func addExpense(_ expense: Expense) async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            let entity = ExpenseEntity(
                id: expense.id,
                title: expense.title,
                details: expense.details,
                amountMinor: expense.amount.amountMinor,
                currencyCode: expense.amount.currencyCode,
                date: expense.date,
                category: Self.categoryEntity(for: expense.category, in: context)
            )
            context.insert(entity)
            try context.save()
        }
    }

    func updateExpense(_ expense: Expense) async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            guard let entity = try Self.expenseEntity(id: expense.id, in: context) else { return }
            entity.title = expense.title
            entity.details = expense.details
            entity.amountMinor = expense.amount.amountMinor
            entity.currencyCode = expense.amount.currencyCode
            entity.date = expense.date
            entity.category = Self.categoryEntity(for: expense.category, in: context)
            try context.save()
        }
    }

    func deleteExpense(id: UUID) async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            guard let entity = try Self.expenseEntity(id: id, in: context) else { return }
            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Helpers

    @MainActor
    private static func expenseEntity(id: UUID, in context: ModelContext) throws -> ExpenseEntity? {
        var descriptor = FetchDescriptor<ExpenseEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private static func categoryEntity(
        for category: ExpenseCategory?,
        in context: ModelContext
    ) -> ExpenseCategoryEntity? {
        guard let category else { return nil }
        let id = category.id
        var descriptor = FetchDescriptor<ExpenseCategoryEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first) ?? nil
    }
}
