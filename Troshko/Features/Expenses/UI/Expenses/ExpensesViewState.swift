import Foundation
import MVVM

enum ExpensesViewState: ViewState {
    case loading
    case loaded(groups: [ExpenseGroup])
    case empty
    case error(String)
}

/// Presentation grouping of expenses under a date heading (Today / This month / Month Year).
struct ExpenseGroup: Identifiable, Equatable {
    let id: String
    let title: String
    let expenses: [Expense]

    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}
