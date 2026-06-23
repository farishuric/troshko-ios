import Foundation
import MVVM

enum CategoryExpensesViewState: ViewState {
    case loading
    case loaded(groups: [ExpenseGroup])
    case empty
    case error(String)
}
