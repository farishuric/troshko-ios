import Foundation
import MVVM

enum AddExpenseViewEvent: ViewEvent {
    case onAppear
    case titleChanged(String)
    case detailsChanged(String)
    case amountChanged(String)
    case dateChanged(Date)
    case categorySelected(ExpenseCategory?)
    case suggestCategoryTapped
    case saveTapped
}
