import Foundation
import MVVM

enum HomeViewModelEvent: ViewModelEvent {
    case presentAddIncome
    case presentSavingsGoal(SavingsGoal?)
}
