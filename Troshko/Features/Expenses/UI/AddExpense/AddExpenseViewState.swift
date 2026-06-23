import Foundation
import MVVM

enum AddExpenseViewState: ViewState {
    case form(FormState)
    case saving
    case error(String)

    struct FormState: Equatable {
        var categories: [ExpenseCategory]
        var canSave: Bool
        var amountError: String?
        var isEditMode: Bool
        var categorySuggestion: CategorySuggestionState
    }

    enum CategorySuggestionState: Equatable {
        case idle
        case loading
        case suggested(ExpenseCategorySuggestion)
        case noSuggestion
        case unavailable
    }
}
