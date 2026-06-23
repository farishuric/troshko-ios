import Foundation
import MVVM

enum AddIncomeViewState: ViewState {
    case form(FormState)
    case saving
    case error(String)

    struct FormState: Equatable {
        var canSave: Bool
        var amountError: String?
    }
}
