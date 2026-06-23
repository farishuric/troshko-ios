import Foundation
import MVVM

enum CategoriesViewState: ViewState {
    case loading
    case loaded(categories: [ExpenseCategory])
    case empty
    case error(String)
}
