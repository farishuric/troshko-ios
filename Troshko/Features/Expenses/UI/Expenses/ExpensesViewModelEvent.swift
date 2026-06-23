import Foundation
import MVVM

enum ExpensesViewModelEvent: ViewModelEvent {
    case presentAddExpense
    case presentEditExpense(Expense)
}
