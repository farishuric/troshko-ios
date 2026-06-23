import Foundation
import MVVM

enum MonthlyOverviewViewState: ViewState {
    case loading
    case loaded(items: [CategorySpending], total: Double)
    case empty
    case error(String)
}
