import SwiftUI
import MVVM
import Styleguide

struct CategoriesView<VM: ViewModel>: View
    where VM.State == CategoriesViewState,
          VM.Event == CategoriesViewEvent,
          VM.VMEvent == CategoriesViewModelEvent
{
    @StateObject private var vm: VM

    @State private var presentingAdd = false
    @State private var pendingDeletion: ExpenseCategory?

    init(vm: VM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isLoading) {
                content
            }
            .navigationTitle("CATEGORIES.TITLE".localized)
            .navigationDestination(for: ExpenseCategory.self) { category in
                CategoryExpensesView(
                    vm: CategoryExpensesViewModel(category: category),
                    title: category.name
                )
            }
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
            case .presentAddCategory:
                presentingAdd = true
            }
        }
        .sheet(isPresented: $presentingAdd) {
            AddCategoryView(
                vm: AddCategoryViewModel(),
                onSaved: { vm.trigger(.reload) }
            )
        }
        .confirmationDialog(
            "CATEGORIES.DELETION.TITLE".localized,
            isPresented: deletionBinding,
            titleVisibility: .visible
        ) {
            Button("WORDING_DELETE".localized, role: .destructive) {
                if let category = pendingDeletion {
                    vm.trigger(.deleteTapped(category))
                }
                pendingDeletion = nil
            }
            Button("WORDING_CANCEL".localized, role: .cancel) {
                pendingDeletion = nil
            }
        } message: {
            Text("CATEGORIES.DELETION.MESSAGE".localized)
        }
    }

    private var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    private var deletionBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        )
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
        case .loaded(let categories):
            list(categories)
        }
    }

    private func list(_ categories: [ExpenseCategory]) -> some View {
        List {
            ForEach(categories) { category in
                NavigationLink(value: category) {
                    Text(category.name)
                        .font(.regular(.body))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                }
                .listRowBackground(SemanticColor.Colors.backgroundPrimary.swiftUIColor)
                .swipeActions(edge: .trailing) {
                    Button("WORDING_DELETE".localized, role: .destructive) {
                        pendingDeletion = category
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "archivebox")
                .font(.system(size: 56))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
            Text("CATEGORIES.NO_DATA".localized)
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
