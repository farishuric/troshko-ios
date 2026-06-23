import Foundation
import MVVM

enum AddCategoryViewState: ViewState {
    case form(canSave: Bool)
    case saving
    case error(String)
}
