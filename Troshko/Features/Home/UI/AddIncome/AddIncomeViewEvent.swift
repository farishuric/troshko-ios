import Foundation
import MVVM

enum AddIncomeViewEvent: ViewEvent {
    case sourceChanged(String)
    case amountChanged(String)
    case dateChanged(Date)
    case saveTapped
}
