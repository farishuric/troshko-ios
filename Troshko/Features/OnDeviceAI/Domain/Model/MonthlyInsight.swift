import Foundation

struct MonthlyInsight: Equatable {
    var title: String
    var message: String
}

struct MonthlyInsightContext: Equatable {
    var income: Money
    var expenses: Money
    var saved: Money
    var savingsGoalName: String?
    var monthlyTarget: Money?
}
