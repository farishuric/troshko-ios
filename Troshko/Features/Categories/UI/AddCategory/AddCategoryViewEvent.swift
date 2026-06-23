import Foundation
import MVVM

enum AddCategoryViewEvent: ViewEvent {
    case nameChanged(String)
    case saveTapped
}
