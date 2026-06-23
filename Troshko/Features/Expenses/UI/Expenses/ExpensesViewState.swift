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

    var total: Money {
        let currencyCode = expenses.first?.amount.currencyCode ?? Money.deviceCurrencyCode
        return expenses.reduce(.zero(currencyCode: currencyCode)) { $0 + $1.amount }
    }
}
