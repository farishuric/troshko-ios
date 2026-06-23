import Foundation
import MVVM

enum ExpensesViewEvent: ViewEvent {
    case onAppear
    case reload
    case addTapped
    case editTapped(Expense)
    case deleteTapped(Expense)
}
