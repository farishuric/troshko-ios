import Foundation

struct HomeSummary: Equatable {
    var greetingKey: String
    var cashflow: MonthlyCashflow
    var savingsGoal: SavingsGoal?
    var tips: [HomeTip]
}

struct HomeTip: Identifiable, Equatable {
    let id: String
    let titleKey: String
    let messageKey: String
}
