import Foundation

struct ExpenseCategorySuggestion: Equatable {
    var category: ExpenseCategory
    var confidence: Confidence
    var reason: String?

    enum Confidence: String, Equatable {
        case low
        case medium
        case high
    }
}
