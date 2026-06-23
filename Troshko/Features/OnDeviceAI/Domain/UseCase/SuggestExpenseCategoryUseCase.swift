import Foundation
import DI

protocol SuggestExpenseCategoryUseCase {
    func execute(
        title: String,
        details: String,
        amount: Money?,
        date: Date,
        categories: [ExpenseCategory]
    ) async throws -> ExpenseCategorySuggestion?
}

final class StandardSuggestExpenseCategoryUseCase: SuggestExpenseCategoryUseCase {
    @Injected private var repository: OnDeviceAIRepository

    func execute(
        title: String,
        details: String,
        amount: Money?,
        date: Date,
        categories: [ExpenseCategory]
    ) async throws -> ExpenseCategorySuggestion? {
        guard !categories.isEmpty else { return nil }

        return try await repository.suggestCategory(
            title: title,
            details: details,
            amount: amount,
            date: date,
            categories: categories
        )
    }
}
