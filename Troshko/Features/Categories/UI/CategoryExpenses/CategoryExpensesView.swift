import SwiftUI
import MVVM
import Styleguide

struct CategoryExpensesView<VM: ViewModel>: View
    where VM.State == CategoryExpensesViewState,
          VM.Event == CategoryExpensesViewEvent,
          VM.VMEvent == EmptyViewModelEvent
{
    @StateObject private var vm: VM
    private let title: String

    init(vm: VM, title: String) {
        _vm = StateObject(wrappedValue: vm)
        self.title = title
    }

    var body: some View {
        BaseScreen(isLoading: isLoading) {
            content
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.trigger(.onAppear) }
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
