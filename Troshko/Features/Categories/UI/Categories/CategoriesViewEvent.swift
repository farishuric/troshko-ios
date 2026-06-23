import Foundation
import MVVM

enum CategoriesViewEvent: ViewEvent {
    case onAppear
    case reload
    case addTapped
    case deleteTapped(ExpenseCategory)
}
