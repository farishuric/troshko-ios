import Foundation
import MVVM

enum HomeViewState: ViewState, Equatable {
    case loading
    case loaded(HomeLoadedState)
    case error(String)
}

struct HomeLoadedState: Equatable {
    var summary: HomeSummary
    var monthlyInsight: MonthlyInsightState
}

enum MonthlyInsightState: Equatable {
    case loading
    case ready(MonthlyInsight)
    case unavailable
}
