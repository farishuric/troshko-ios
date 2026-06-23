import Foundation
import MVVM

enum SavingsGoalViewEvent: ViewEvent {
    case nameChanged(String)
    case targetAmountChanged(String)
    case monthlyTargetChanged(String)
    case saveTapped
}
