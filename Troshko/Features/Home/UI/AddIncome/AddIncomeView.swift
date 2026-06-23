import SwiftUI
import MVVM
import Styleguide

struct AddIncomeView<VM: ViewModel>: View
    where VM.State == AddIncomeViewState,
          VM.Event == AddIncomeViewEvent,
          VM.VMEvent == AddIncomeViewModelEvent
{
    @StateObject private var vm: VM
    private let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var source = ""
    @State private var amount = ""
    @State private var date = Date()
    @FocusState private var isSourceFocused: Bool
    @FocusState private var isAmountFocused: Bool

    init(vm: VM, onSaved: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: vm)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isSaving) {
                content
            }
            .navigationTitle("HOME.INCOME.ADD_TITLE".localized)
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
                        Text("HOME.INCOME.SAVE".localized)
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

    private func formView(_ form: AddIncomeViewState.FormState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.Semantic.sectionSpacing) {
                AppTextField(
                    title: LocalizedStringKey("HOME.INCOME.SOURCE"),
                    placeholder: LocalizedStringKey("HOME.INCOME.SOURCE_PLACEHOLDER"),
                    text: $source,
                    focus: $isSourceFocused,
                    submitLabel: .next,
                    onSubmit: { isAmountFocused = true }
                )
                .onValueChange(of: source) { vm.trigger(.sourceChanged($0)) }

                amountField(error: form.amountError)

                DatePicker("HOME.INCOME.DATE".localized, selection: $date, displayedComponents: .date)
                    .font(.semibold(.body))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                    .onValueChange(of: date) { vm.trigger(.dateChanged($0)) }
            }
            .padding(.horizontal, Spacing.Semantic.screenMargin)
            .padding(.top, Spacing.Semantic.sectionSpacing)
            .padding(.bottom, Spacing.Semantic.buttonHeightLarge)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func amountField(error: String?) -> some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.componentMargin) {
            Text("HOME.INCOME.AMOUNT".localized)
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

            HStack(spacing: Spacing.Semantic.groupSpacing) {
                Text(Money.currencySymbol(for: Money.deviceCurrencyCode))
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                TextField("HOME.INCOME.AMOUNT_PLACEHOLDER".localized, text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textFieldText.swiftUIColor)
                    .tint(SemanticColor.Colors.primary.swiftUIColor)
                    .focused($isAmountFocused)
                    .onValueChange(of: amount) { vm.trigger(.amountChanged($0)) }
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
        isSourceFocused = false
        isAmountFocused = false
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
