import SwiftUI
import MVVM
import Styleguide

struct ExpensesView<VM: ViewModel>: View
    where VM.State == ExpensesViewState,
          VM.Event == ExpensesViewEvent,
          VM.VMEvent == ExpensesViewModelEvent
{
    @StateObject private var vm: VM

    @State private var route: AddExpenseRoute?

    init(vm: VM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isLoading, showsAmbientBackground: true) {
                content
            }
            .navigationTitle("EXPENSES.TITLE".localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.trigger(.addTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                }
            }
        }
        .onAppear { vm.trigger(.onAppear) }
        .onReceive(vm.eventPublisher) { event in
            switch event {
            case .presentAddExpense:
                route = AddExpenseRoute(expense: nil)
            case .presentEditExpense(let expense):
                route = AddExpenseRoute(expense: expense)
            }
        }
        .sheet(item: $route) { route in
            AddExpenseView(
                vm: AddExpenseViewModel(editing: route.expense),
                editing: route.expense,
                onSaved: { vm.trigger(.reload) }
            )
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
        case .empty:
            emptyState
        case .error(let message):
            errorState(message)
        case .loaded(let groups):
            list(groups)
        }
    }

    private func list(_ groups: [ExpenseGroup]) -> some View {
        List {
            expenseSummary(groups)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: Spacing.Semantic.screenMargin,
                    leading: Spacing.Semantic.screenMargin,
                    bottom: Spacing.Semantic.itemSpacing,
                    trailing: Spacing.Semantic.screenMargin
                ))
                .listRowBackground(Color.clear)

            ForEach(Array(groups.enumerated()), id: \.element.id) { groupIndex, group in
                Section {
                    ForEach(Array(group.expenses.enumerated()), id: \.element.id) { rowIndex, expense in
                        ExpenseRow(expense: expense)
                            .softAppear(index: rowEntranceIndex(groups, groupIndex, rowIndex))
                            .floatingListRow()
                            .contentShape(Rectangle())
                            .swipeActions(edge: .leading) {
                                Button("WORDING_EDIT".localized) {
                                    vm.trigger(.editTapped(expense))
                                }
                                .tint(SemanticColor.Colors.primary.swiftUIColor)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("WORDING_DELETE".localized, role: .destructive) {
                                    vm.trigger(.deleteTapped(expense))
                                }
                            }
                    }
                } header: {
                    sectionHeader(group)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    /// Flat running index across all groups so the calm entrance cascades down the
    /// whole list, not just within each day-section.
    private func rowEntranceIndex(_ groups: [ExpenseGroup], _ groupIndex: Int, _ rowIndex: Int) -> Int {
        let preceding = groups[..<groupIndex].reduce(0) { $0 + $1.expenses.count }
        return preceding + rowIndex
    }

    private func expenseSummary(_ groups: [ExpenseGroup]) -> some View {
        let expenses = groups.flatMap(\.expenses)
        let total = totalAmount(for: expenses)

        return FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                HStack(alignment: .top, spacing: Spacing.Semantic.itemSpacing) {
                    VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                        Text("EXPENSES.SUMMARY.TITLE".localized)
                            .font(.regular(.small))
                            .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        Text(total.formatted())
                            .font(.bold(.title))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    }

                    Spacer(minLength: Spacing.Semantic.itemSpacing)

                    Image(systemName: "creditcard.fill")
                        .font(.semibold(.large))
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                        .frame(
                            width: Spacing.Semantic.minimumTouchTarget,
                            height: Spacing.Semantic.minimumTouchTarget
                        )
                        .background(
                            Circle().fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.14))
                        )
                }

                Text("EXPENSES.SUMMARY.COUNT".localized(arguments: expenses.count))
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
            }
        }
        .softAppear()
    }

    private func sectionHeader(_ group: ExpenseGroup) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.Semantic.itemSpacing) {
            Text(group.title)
                .font(.semibold(.small))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)

            Spacer(minLength: Spacing.Semantic.itemSpacing)

            Text(group.total.formatted())
                .font(.semibold(.small))
                .foregroundStyle(SemanticColor.Colors.textTertiary.swiftUIColor)
        }
        .textCase(nil)
        .padding(.horizontal, Spacing.Semantic.screenMargin)
        .padding(.top, Spacing.Semantic.groupSpacing)
        .padding(.bottom, Spacing.Semantic.componentMargin)
    }

    private func totalAmount(for expenses: [Expense]) -> Money {
        let currencyCode = expenses.first?.amount.currencyCode ?? Money.deviceCurrencyCode
        return expenses.reduce(.zero(currencyCode: currencyCode)) { $0 + $1.amount }
    }

    private var emptyState: some View {
        VStack {
            Spacer(minLength: Spacing.Semantic.sectionSpacing)

            FloatingCard {
                VStack(spacing: Spacing.Semantic.itemSpacing) {
                    Image(systemName: "creditcard.fill")
                        .font(.bold(.title))
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                        .frame(
                            width: Spacing.Semantic.buttonHeightLarge,
                            height: Spacing.Semantic.buttonHeightLarge
                        )
                        .background(
                            Circle().fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.14))
                        )

                    VStack(spacing: Spacing.Semantic.groupSpacing) {
                        Text("EXPENSES.EMPTY.TITLE".localized)
                            .font(.semibold(.title))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                            .multilineTextAlignment(.center)

                        Text("EXPENSES.EMPTY.MESSAGE".localized)
                            .font(.regular(.body))
                            .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PrimaryButton(action: { vm.trigger(.addTapped) }) {
                        Label("ADD_EXPENSE".localized, systemImage: "plus")
                    }
                    .padding(.top, Spacing.Semantic.groupSpacing)
                }
                .frame(maxWidth: .infinity)
            }
            .softAppear()
            .padding(Spacing.Semantic.screenMargin)

            Spacer(minLength: Spacing.Semantic.sectionSpacing)
        }
    }

    private func errorState(_ message: String) -> some View {
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
            .frame(maxWidth: .infinity)
        }
        .softAppear()
        .padding(Spacing.Semantic.screenMargin)
    }
}

/// Identifiable route for the add/edit sheet. `expense == nil` means a new expense.
struct AddExpenseRoute: Identifiable {
    let id = UUID()
    let expense: Expense?
}
