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
            BaseScreen(isLoading: isLoading) {
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
            ForEach(groups) { group in
                Section {
                    ForEach(group.expenses) { expense in
                        ExpenseRow(expense: expense)
                            .listRowBackground(SemanticColor.Colors.backgroundPrimary.swiftUIColor)
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
                    Text(group.title)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "doc.text")
                .font(.system(size: 56))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
            Text("EXPENSES.NO_EXPENSES".localized)
                .font(.regular(.body))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.Semantic.screenMargin)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(SemanticColor.Colors.error.swiftUIColor)
            Text(message)
                .font(.regular(.body))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                .multilineTextAlignment(.center)
            Button("WORDING_RETRY".localized) { vm.trigger(.reload) }
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
        }
        .padding(Spacing.Semantic.screenMargin)
    }
}

/// Identifiable route for the add/edit sheet. `expense == nil` means a new expense.
struct AddExpenseRoute: Identifiable {
    let id = UUID()
    let expense: Expense?
}
