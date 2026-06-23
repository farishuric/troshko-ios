import Combine
import Foundation
import DI
import MVVM

final class HomeViewModel: ViewModel {
    @Published private(set) var state: HomeViewState = .loading

    private let eventSubject = PassthroughSubject<HomeViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<HomeViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getHomeSummary: GetHomeSummaryUseCase
    @Injected private var generateMonthlyInsight: GenerateMonthlyInsightUseCase

    func trigger(_ event: HomeViewEvent) {
        switch event {
        case .onAppear, .reload:
            load()
        case .addIncomeTapped:
            eventSubject.send(.presentAddIncome)
        case .savingsGoalTapped:
            eventSubject.send(.presentSavingsGoal(currentGoal))
        }
    }

    private var currentGoal: SavingsGoal? {
        guard case .loaded(let loaded) = state else { return nil }
        return loaded.summary.savingsGoal
    }

    private func load() {
        Task { @MainActor in
            state = .loading
            do {
                let summary = try await getHomeSummary.execute(for: Date())
                state = .loaded(HomeLoadedState(summary: summary, monthlyInsight: .loading))
                loadMonthlyInsight(for: summary)
            } catch {
                state = .error("HOME.LOAD_ERROR".localized)
            }
        }
    }

    private func loadMonthlyInsight(for summary: HomeSummary) {
        Task { @MainActor in
            let insightState: MonthlyInsightState
            do {
                if let insight = try await generateMonthlyInsight.execute(
                    context: MonthlyInsightContext(summary: summary),
                    month: Date()
                ) {
                    insightState = .ready(insight)
                } else {
                    insightState = .ready(Self.fallbackInsight(for: summary))
                }
            } catch {
                insightState = .ready(Self.fallbackInsight(for: summary))
            }

            guard case .loaded(var loaded) = state, loaded.summary == summary else { return }
            loaded.monthlyInsight = insightState
            state = .loaded(loaded)
        }
    }

    private static func fallbackInsight(for summary: HomeSummary) -> MonthlyInsight {
        if summary.cashflow.saved.amountMinor > 0 {
            return MonthlyInsight(
                title: "HOME.AI_INSIGHT.FALLBACK_POSITIVE_TITLE".localized,
                message: "HOME.AI_INSIGHT.FALLBACK_POSITIVE_MESSAGE".localized(
                    arguments: summary.cashflow.saved.formatted()
                )
            )
        }

        if summary.cashflow.saved.amountMinor < 0 {
            return MonthlyInsight(
                title: "HOME.AI_INSIGHT.FALLBACK_NEGATIVE_TITLE".localized,
                message: "HOME.AI_INSIGHT.FALLBACK_NEGATIVE_MESSAGE".localized(
                    arguments: summary.cashflow.expenses.formatted()
                )
            )
        }

        return MonthlyInsight(
            title: "HOME.AI_INSIGHT.FALLBACK_BALANCED_TITLE".localized,
            message: "HOME.AI_INSIGHT.FALLBACK_BALANCED_MESSAGE".localized
        )
    }
}

private extension MonthlyInsightContext {
    init(summary: HomeSummary) {
        self.init(
            income: summary.cashflow.income,
            expenses: summary.cashflow.expenses,
            saved: summary.cashflow.saved,
            savingsGoalName: summary.savingsGoal?.name,
            monthlyTarget: summary.savingsGoal?.monthlyTarget
        )
    }
}
