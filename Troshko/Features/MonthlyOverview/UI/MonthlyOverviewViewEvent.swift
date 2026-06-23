import Foundation
import MVVM

enum MonthlyOverviewViewEvent: ViewEvent {
    /// Load (or reload) the overview for the given month.
    case load(Date)
}
