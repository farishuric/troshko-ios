import SwiftUI
import MVVM
import Styleguide

struct HomeView<VM: ViewModel>: View
    where VM.State == HomeViewState,
          VM.Event == HomeViewEvent,
          VM.VMEvent == HomeViewModelEvent
{
    @StateObject private var vm: VM
    @State private var route: HomeRoute?

    init(vm: VM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isLoading, showsAmbientBackground: true) {
                content
            }
            .navigationTitle("HOME.TITLE".localized)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ProfileMenuButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.trigger(.addIncomeTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                    .accessibilityLabel(Text("HOME.ADD_INCOME".localized))
                }
            }
        }
        .onAppear { vm.trigger(.onAppear) }
        .onReceive(vm.eventPublisher) { event in
            switch event {
            case .presentAddIncome:
                route = .addIncome
            case .presentSavingsGoal(let goal):
                route = .savingsGoal(goal)
            }
        }
        .sheet(item: $route) { route in
            switch route {
            case .addIncome:
                AddIncomeView(vm: AddIncomeViewModel()) {
                    vm.trigger(.reload)
                }
            case .savingsGoal(let goal):
                SavingsGoalView(vm: SavingsGoalViewModel(editing: goal), editing: goal) {
                    vm.trigger(.reload)
                }
            }
        }
    }

    private var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            Color.clear
        case .loaded(let loaded):
            loadedView(loaded)
        case .error(let message):
            errorState(message)
        }
    }

    private func loadedView(_ loaded: HomeLoadedState) -> some View {
        let summary = loaded.summary

        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.Semantic.sectionSpacing) {
                greetingCard(summary)
                    .softAppear()
                savedCard(summary)
                    .softAppear(index: 1)
                monthlyInsightCard(loaded.monthlyInsight)
                    .softAppear(index: 2)
                goalCard(summary)
                    .softAppear(index: 3)
                tipBanners(summary.tips)
            }
            .padding(Spacing.Semantic.screenMargin)
        }
    }

    private func greetingCard(_ summary: HomeSummary) -> some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                Text(summary.greetingKey.localized)
                    .font(.bold(.title))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                Text("HOME.GREETING.SUBTITLE".localized)
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func savedCard(_ summary: HomeSummary) -> some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                HStack(alignment: .top, spacing: Spacing.Semantic.itemSpacing) {
                    VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                        Text("HOME.SAVED_THIS_MONTH".localized)
                            .font(.regular(.small))
                            .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        Text(summary.cashflow.saved.formatted())
                            .font(.bold(.title))
                            .foregroundStyle(savedAmountColor(summary.cashflow.saved))
                    }

                    Spacer(minLength: Spacing.Semantic.itemSpacing)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.semibold(.large))
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                        .frame(
                            width: Spacing.Semantic.minimumTouchTarget,
                            height: Spacing.Semantic.minimumTouchTarget
                        )
                }

                VStack(spacing: Spacing.Semantic.groupSpacing) {
                    cashflowRow(
                        title: "HOME.INCOME_THIS_MONTH".localized,
                        value: summary.cashflow.income.formatted()
                    )
                    cashflowRow(
                        title: "HOME.SPENT_THIS_MONTH".localized,
                        value: summary.cashflow.expenses.formatted()
                    )
                }

                PrimaryButton(action: { vm.trigger(.addIncomeTapped) }) {
                    Label("HOME.ADD_INCOME".localized, systemImage: "plus")
                }
            }
        }
    }

    private func goalCard(_ summary: HomeSummary) -> some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                HStack(alignment: .top, spacing: Spacing.Semantic.itemSpacing) {
                    VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                        Text("HOME.GOAL.TITLE".localized)
                            .font(.semibold(.large))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                        Text(goalSubtitle(summary))
                            .font(.regular(.small))
                            .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: Spacing.Semantic.itemSpacing)

                    Button {
                        vm.trigger(.savingsGoalTapped)
                    } label: {
                        Image(systemName: summary.savingsGoal == nil ? "target" : "slider.horizontal.3")
                            .font(.semibold(.body))
                    }
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                    .accessibilityLabel(Text("HOME.GOAL.EDIT".localized))
                }

                if let goal = summary.savingsGoal {
                    ProgressView(value: goalProgress(summary, goal: goal))
                        .tint(SemanticColor.Colors.primary.swiftUIColor)
                    Text(goalProgressText(summary, goal: goal))
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                }

                PrimaryButton(action: { vm.trigger(.savingsGoalTapped) }) {
                    Label(
                        summary.savingsGoal == nil ? "HOME.GOAL.SET".localized : "HOME.GOAL.UPDATE".localized,
                        systemImage: "target"
                    )
                }
            }
        }
    }

    private func monthlyInsightCard(_ state: MonthlyInsightState) -> some View {
        FloatingCard {
            HStack(alignment: .top, spacing: Spacing.Semantic.itemSpacing) {
                Image(systemName: "sparkles")
                    .font(.semibold(.large))
                    .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)

                VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                    Text(insightTitle(state))
                        .font(.semibold(.body))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    Text(insightMessage(state))
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func tipBanners(_ tips: [HomeTip]) -> some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            ForEach(Array(tips.enumerated()), id: \.element.id) { index, tip in
                Banner(
                    style: .tip,
                    title: tip.titleKey.localized,
                    message: tip.messageKey.localized
                )
                .softAppear(index: index + 4)
            }
        }
    }

    private func insightTitle(_ state: MonthlyInsightState) -> String {
        switch state {
        case .loading:
            return "HOME.AI_INSIGHT.LOADING_TITLE".localized
        case .ready(let insight):
            return insight.title
        case .unavailable:
            return "HOME.AI_INSIGHT.UNAVAILABLE_TITLE".localized
        }
    }

    private func insightMessage(_ state: MonthlyInsightState) -> String {
        switch state {
        case .loading:
            return "HOME.AI_INSIGHT.LOADING_MESSAGE".localized
        case .ready(let insight):
            return insight.message
        case .unavailable:
            return "HOME.AI_INSIGHT.UNAVAILABLE_MESSAGE".localized
        }
    }

    private func cashflowRow(title: String, value: String) -> some View {
        HStack(spacing: Spacing.Semantic.itemSpacing) {
            Text(title)
                .font(.regular(.small))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
            Spacer(minLength: Spacing.Semantic.itemSpacing)
            Text(value)
                .font(.semibold(.small))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                .multilineTextAlignment(.trailing)
        }
    }

    private func goalSubtitle(_ summary: HomeSummary) -> String {
        guard let goal = summary.savingsGoal else {
            return "HOME.GOAL.EMPTY".localized
        }
        return "HOME.GOAL.SUBTITLE".localized(arguments: goal.name, goal.targetAmount.formatted())
    }

    private func goalProgressText(_ summary: HomeSummary, goal: SavingsGoal) -> String {
        let saved = Money(
            amountMinor: max(0, summary.cashflow.saved.amountMinor),
            currencyCode: summary.cashflow.saved.currencyCode
        )
        return "HOME.GOAL.PROGRESS".localized(arguments: saved.formatted(), goal.monthlyTarget.formatted())
    }

    private func goalProgress(_ summary: HomeSummary, goal: SavingsGoal) -> Double {
        guard goal.monthlyTarget.amountMinor > 0 else { return 0 }
        let clamped = min(max(0, summary.cashflow.saved.amountMinor), goal.monthlyTarget.amountMinor)
        return Double(clamped) / Double(goal.monthlyTarget.amountMinor)
    }

    private func savedAmountColor(_ money: Money) -> Color {
        money.amountMinor >= 0
            ? SemanticColor.Colors.success.swiftUIColor
            : SemanticColor.Colors.textWarning.swiftUIColor
    }

    private func errorState(_ message: String) -> some View {
        VStack {
            Spacer(minLength: Spacing.Semantic.sectionSpacing)
            FloatingCard {
                VStack(spacing: Spacing.Semantic.itemSpacing) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.bold(.title))
                        .foregroundStyle(SemanticColor.Colors.error.swiftUIColor)
                    Text(message)
                        .font(.regular(.body))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        .multilineTextAlignment(.center)
                    Button("WORDING_RETRY".localized) { vm.trigger(.reload) }
                        .font(.semibold(.body))
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                }
            }
            .padding(Spacing.Semantic.screenMargin)
            Spacer(minLength: Spacing.Semantic.sectionSpacing)
        }
    }
}

private enum HomeRoute: Identifiable {
    case addIncome
    case savingsGoal(SavingsGoal?)

    var id: String {
        switch self {
        case .addIncome:
            return "add-income"
        case .savingsGoal(let goal):
            return "savings-goal-\(goal?.id.uuidString ?? "new")"
        }
    }
}
