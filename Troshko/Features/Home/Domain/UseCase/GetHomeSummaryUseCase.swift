import Foundation
import DI

protocol GetHomeSummaryUseCase {
    func execute(for date: Date) async throws -> HomeSummary
}

final class StandardGetHomeSummaryUseCase: GetHomeSummaryUseCase {
    @Injected private var getExpenses: GetExpensesUseCase
    @Injected private var fetchIncomeEntries: FetchIncomeEntriesUseCase
    @Injected private var fetchSavingsGoal: FetchSavingsGoalUseCase

    func execute(for date: Date = Date()) async throws -> HomeSummary {
        let expenses = try await getExpenses.execute()
        let incomeEntries = try await fetchIncomeEntries.execute()
        let goal = try await fetchSavingsGoal.execute()
        let month = Calendar.current.dateInterval(of: .month, for: date)

        let monthExpenses = expenses.filter { expense in
            guard let month else { return false }
            return month.contains(expense.date)
        }
        let monthIncome = incomeEntries.filter { entry in
            guard let month else { return false }
            return month.contains(entry.date)
        }

        let currencyCode = monthIncome.first?.amount.currencyCode
            ?? monthExpenses.first?.amount.currencyCode
            ?? goal?.monthlyTarget.currencyCode
            ?? Money.deviceCurrencyCode

        let income = monthIncome.reduce(.zero(currencyCode: currencyCode)) { $0 + $1.amount }
        let spent = monthExpenses.reduce(.zero(currencyCode: currencyCode)) { $0 + $1.amount }
        let cashflow = MonthlyCashflow(income: income, expenses: spent, saved: income - spent)

        return HomeSummary(
            greetingKey: Self.greetingKey(for: date),
            cashflow: cashflow,
            savingsGoal: goal,
            tips: Self.tips(for: cashflow, goal: goal)
        )
    }

    private static func greetingKey(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "HOME.GREETING.MORNING"
        case 12..<18: return "HOME.GREETING.AFTERNOON"
        default: return "HOME.GREETING.EVENING"
        }
    }

    private static func tips(for cashflow: MonthlyCashflow, goal: SavingsGoal?) -> [HomeTip] {
        var tips: [HomeTip] = []

        if cashflow.saved.amountMinor >= 0 {
            tips.append(HomeTip(
                id: "positive-cashflow",
                titleKey: "HOME.TIP.POSITIVE.TITLE",
                messageKey: "HOME.TIP.POSITIVE.MESSAGE"
            ))
        } else {
            tips.append(HomeTip(
                id: "negative-cashflow",
                titleKey: "HOME.TIP.NEGATIVE.TITLE",
                messageKey: "HOME.TIP.NEGATIVE.MESSAGE"
            ))
        }

        if goal == nil {
            tips.append(HomeTip(
                id: "set-goal",
                titleKey: "HOME.TIP.GOAL.TITLE",
                messageKey: "HOME.TIP.GOAL.MESSAGE"
            ))
        } else {
            tips.append(HomeTip(
                id: "goal-check",
                titleKey: "HOME.TIP.GOAL_CHECK.TITLE",
                messageKey: "HOME.TIP.GOAL_CHECK.MESSAGE"
            ))
        }

        return tips
    }
}
