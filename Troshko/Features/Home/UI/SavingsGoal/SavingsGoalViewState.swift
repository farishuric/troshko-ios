import Foundation
import MVVM

enum SavingsGoalViewState: ViewState {
    case form(FormState)
    case saving
    case error(String)

    struct FormState: Equatable {
        var canSave: Bool
        var targetAmountError: String?
        var monthlyTargetError: String?
        var isEditMode: Bool
    }
}
