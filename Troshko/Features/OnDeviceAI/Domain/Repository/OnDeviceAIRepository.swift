import Foundation

enum OnDeviceAIError: Error {
    case unavailable
}

protocol OnDeviceAIRepository {
    func suggestCategory(
        title: String,
        details: String,
        amount: Money?,
        date: Date,
        categories: [ExpenseCategory]
    ) async throws -> ExpenseCategorySuggestion?

    func generateMonthlyInsight(context: MonthlyInsightContext, month: Date) async throws -> MonthlyInsight?
}
