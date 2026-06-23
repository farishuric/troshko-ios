import Foundation
import DI

/// Aggregates the month's expenses into per-category spending totals (newest spend first).
/// Reuses the Expenses feature's `GetExpensesUseCase` rather than touching persistence,
/// so the overview always reflects the same unified store.
protocol GetMonthlyOverviewUseCase {
    func execute(for date: Date) async throws -> [CategorySpending]
}

final class StandardGetMonthlyOverviewUseCase: GetMonthlyOverviewUseCase {
    @Injected private var getExpenses: GetExpensesUseCase

    func execute(for date: Date) async throws -> [CategorySpending] {
        let expenses = try await getExpenses.execute()

        let calendar = Calendar.current
        guard
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
            let end = calendar.date(byAdding: DateComponents(month: 1), to: start)
        else { return [] }

        let uncategorized = "MONTHLY_OVERVIEW.UNCATEGORIZED".localized

        var totals: [String: Money] = [:]
        var order: [String] = []
        for expense in expenses where expense.date >= start && expense.date < end {
            let name = expense.category?.name ?? uncategorized
            if let total = totals[name] {
                totals[name] = total + expense.amount
            } else {
                order.append(name)
                totals[name] = expense.amount
            }
        }

        return order
            .map { CategorySpending(categoryName: $0, total: totals[$0] ?? .zero()) }
            .sorted { $0.total.amountMinor > $1.total.amountMinor }
    }
}
