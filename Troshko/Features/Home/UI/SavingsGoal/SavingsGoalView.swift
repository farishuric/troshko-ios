import SwiftUI
import MVVM
import Styleguide

struct SavingsGoalView<VM: ViewModel>: View
    where VM.State == SavingsGoalViewState,
          VM.Event == SavingsGoalViewEvent,
          VM.VMEvent == SavingsGoalViewModelEvent
{
    @StateObject private var vm: VM
    private let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var targetAmount: String
    @State private var monthlyTarget: String
    @FocusState private var isNameFocused: Bool
    @FocusState private var isTargetFocused: Bool
    @FocusState private var isMonthlyFocused: Bool
    private let currencyCode: String

    init(vm: VM, editing: SavingsGoal?, onSaved: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: vm)
        self.onSaved = onSaved
        self.currencyCode = editing?.targetAmount.currencyCode ?? Money.deviceCurrencyCode
        _name = State(initialValue: editing?.name ?? "")
        _targetAmount = State(initialValue: editing?.targetAmount.inputText() ?? "")
        _monthlyTarget = State(initialValue: editing?.monthlyTarget.inputText() ?? "")
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isSaving) {
                content
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("WORDING_CANCEL".localized) { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("WORDING_DONE".localized) {
                        clearFocus()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if case .form(let form) = vm.state {
                    PrimaryButton(action: { vm.trigger(.saveTapped) }) {
                        Text("WORDING_SAVE".localized)
                    }
                    .disabled(!form.canSave)
                    .padding(.horizontal, Spacing.Semantic.screenMargin)
                    .padding(.vertical, Spacing.Semantic.componentMargin)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onReceive(vm.eventPublisher) { event in
            switch event {
            case .saved:
                onSaved()
                dismiss()
            }
        }
    }

    private var navigationTitle: String {
        if case .form(let form) = vm.state, form.isEditMode {
            return "HOME.GOAL.EDIT_TITLE".localized
        }
        return "HOME.GOAL.SET_TITLE".localized
    }

    private var isSaving: Bool {
        if case .saving = vm.state { return true }
        return false
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .error(let message):
            errorView(message)
        case .form(let form):
            formView(form)
        case .saving:
            Color.clear
        }
    }

    private func formView(_ form: SavingsGoalViewState.FormState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.Semantic.sectionSpacing) {
                AppTextField(
                    title: LocalizedStringKey("HOME.GOAL.NAME"),
                    placeholder: LocalizedStringKey("HOME.GOAL.NAME_PLACEHOLDER"),
                    text: $name,
                    focus: $isNameFocused,
                    submitLabel: .next,
                    onSubmit: { isTargetFocused = true }
                )
                .onValueChange(of: name) { vm.trigger(.nameChanged($0)) }

                moneyField(
                    title: "HOME.GOAL.TARGET_AMOUNT".localized,
                    text: $targetAmount,
                    focused: $isTargetFocused,
                    error: form.targetAmountError
                )
                .onValueChange(of: targetAmount) { vm.trigger(.targetAmountChanged($0)) }

                moneyField(
                    title: "HOME.GOAL.MONTHLY_TARGET".localized,
                    text: $monthlyTarget,
                    focused: $isMonthlyFocused,
                    error: form.monthlyTargetError
                )
                .onValueChange(of: monthlyTarget) { vm.trigger(.monthlyTargetChanged($0)) }
            }
            .padding(.horizontal, Spacing.Semantic.screenMargin)
            .padding(.top, Spacing.Semantic.sectionSpacing)
            .padding(.bottom, Spacing.Semantic.buttonHeightLarge)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func moneyField(
        title: String,
        text: Binding<String>,
        focused: FocusState<Bool>.Binding,
        error: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.componentMargin) {
            Text(title)
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

            HStack(spacing: Spacing.Semantic.groupSpacing) {
                Text(Money.currencySymbol(for: currencyCode))
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                TextField("HOME.INCOME.AMOUNT_PLACEHOLDER".localized, text: text)
                    .keyboardType(.decimalPad)
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textFieldText.swiftUIColor)
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                    .focused(focused)
            }
            .padding(Spacing.Semantic.componentPadding)
            .background(SemanticColor.Colors.textFieldBG.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusLarge)
                    .stroke(
                        error == nil
                            ? SemanticColor.Colors.borderPrimary.swiftUIColor
                            : SemanticColor.Colors.borderError.swiftUIColor,
                        lineWidth: Spacing.Semantic.borderWidth
                    )
            )

            if let error {
                Text(error)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textError.swiftUIColor)
            }
        }
    }

    private func clearFocus() {
        isNameFocused = false
        isTargetFocused = false
        isMonthlyFocused = false
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.bold(.title))
                .foregroundStyle(SemanticColor.Colors.error.swiftUIColor)
            Text(message)
                .font(.regular(.body))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                .multilineTextAlignment(.center)
            Button("WORDING_RETRY".localized) { vm.trigger(.saveTapped) }
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
        }
        .padding(Spacing.Semantic.screenMargin)
    }
}
