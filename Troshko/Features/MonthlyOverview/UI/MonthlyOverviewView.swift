import SwiftUI
import MVVM
import Styleguide

struct MonthlyOverviewView<VM: ViewModel>: View
    where VM.State == MonthlyOverviewViewState,
          VM.Event == MonthlyOverviewViewEvent,
          VM.VMEvent == EmptyViewModelEvent
{
    @StateObject private var vm: VM

    @State private var selectedDate = Date()
    @State private var presentingPicker = false

    init(vm: VM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isLoading) {
                content
            }
            .navigationTitle("MONTHLY_OVERVIEW.NAV_TITLE".localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        presentingPicker = true
                    } label: {
                        Label(monthLabel, systemImage: "chevron.down")
                            .font(.semibold(.body))
                    }
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                }
            }
            .sheet(isPresented: $presentingPicker) {
                MonthYearPickerSheet(selectedDate: $selectedDate)
                    .presentationDetents([.medium])
            }
        }
        .onAppear { vm.trigger(.load(selectedDate)) }
        .onChange(of: selectedDate) { _, newValue in
            vm.trigger(.load(newValue))
        }
    }

    private var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    private var monthLabel: String {
        selectedDate.formatted(.dateTime.month(.wide).year()).capitalized
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
        case .loaded(let items, let total):
            loaded(items: items, total: total)
        }
    }

    private func loaded(items: [CategorySpending], total: Money) -> some View {
        VStack {
            Spacer(minLength: 0)
            SpendingDonutChart(items: items)
            Spacer(minLength: 0)
            Text("MONTHLY_OVERVIEW.TOTAL_EXPENSES".localized(arguments: total.formatted()))
                .font(.semibold(.large))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                .padding(Spacing.Semantic.screenMargin)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "chart.pie")
                .font(.system(size: 56))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
            Text("MONTHLY_OVERVIEW.NO_DATA".localized)
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
            Button("WORDING_RETRY".localized) { vm.trigger(.load(selectedDate)) }
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
        }
        .padding(Spacing.Semantic.screenMargin)
    }
}
