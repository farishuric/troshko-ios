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
            BaseScreen(isLoading: isLoading, showsAmbientBackground: true) {
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
                ToolbarItem(placement: .topBarLeading) {
                    ProfileMenuButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.trigger(.addTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                    .accessibilityLabel(Text("CATEGORIES.ADD.CATEGORY".localized))
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
            categoriesSummary(categories)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: Spacing.Semantic.screenMargin,
                    leading: Spacing.Semantic.screenMargin,
                    bottom: Spacing.Semantic.itemSpacing,
                    trailing: Spacing.Semantic.screenMargin
                ))
                .listRowBackground(Color.clear)

            ForEach(categories) { category in
                NavigationLink(value: category) {
                    categoryRow(category)
                }
                .softAppear(index: categories.firstIndex(of: category) ?? 0)
                .floatingListRow()
                .swipeActions(edge: .trailing) {
                    Button("WORDING_DELETE".localized, role: .destructive) {
                        pendingDeletion = category
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func categoriesSummary(_ categories: [ExpenseCategory]) -> some View {
        FloatingCard {
            HStack(alignment: .top, spacing: Spacing.Semantic.itemSpacing) {
                VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                    Text("CATEGORIES.SUMMARY.TITLE".localized)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                    Text("CATEGORIES.SUMMARY.COUNT".localized(arguments: categories.count))
                        .font(.bold(.title))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    Text("CATEGORIES.SUMMARY.MESSAGE".localized)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: Spacing.Semantic.itemSpacing)

                Image(systemName: "archivebox.fill")
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
        }
        .softAppear()
    }

    private func categoryRow(_ category: ExpenseCategory) -> some View {
        HStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "folder.fill")
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                .frame(
                    width: Spacing.Semantic.minimumTouchTarget,
                    height: Spacing.Semantic.minimumTouchTarget
                )
                .background(
                    Circle().fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                Text(category.name)
                    .font(.semibold(.body))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                Text("CATEGORIES.ROW.SUBTITLE".localized)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
            }

            Spacer(minLength: Spacing.Semantic.itemSpacing)
        }
        .padding(.vertical, Spacing.Semantic.groupSpacing)
    }

    private var emptyState: some View {
        VStack {
            Spacer(minLength: Spacing.Semantic.sectionSpacing)

            FloatingCard {
                VStack(spacing: Spacing.Semantic.itemSpacing) {
                    Image(systemName: "archivebox.fill")
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
                        Text("CATEGORIES.EMPTY.TITLE".localized)
                            .font(.semibold(.title))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                            .multilineTextAlignment(.center)

                        Text("CATEGORIES.EMPTY.MESSAGE".localized)
                            .font(.regular(.body))
                            .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PrimaryButton(action: { vm.trigger(.addTapped) }) {
                        Label("CATEGORIES.ADD.CATEGORY".localized, systemImage: "plus")
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
                .frame(maxWidth: .infinity)
            }
            .softAppear()
            .padding(Spacing.Semantic.screenMargin)

            Spacer(minLength: Spacing.Semantic.sectionSpacing)
        }
    }
}
