import SwiftUI
import MVVM
import Styleguide

struct AddExpenseView<VM: ViewModel>: View
    where VM.State == AddExpenseViewState,
          VM.Event == AddExpenseViewEvent,
          VM.VMEvent == AddExpenseViewModelEvent
{
    @StateObject private var vm: VM
    private let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var details: String
    @State private var amount: String
    @State private var date: Date
    @State private var selectedCategoryID: UUID?
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDetailsFocused: Bool
    @FocusState private var isAmountFocused: Bool
    private let currencyCode: String

    init(vm: VM, editing: Expense?, onSaved: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: vm)
        self.onSaved = onSaved
        self.currencyCode = editing?.amount.currencyCode ?? Money.deviceCurrencyCode
        _title = State(initialValue: editing?.title ?? "")
        _details = State(initialValue: editing?.details ?? "")
        _amount = State(initialValue: editing?.amount.inputText() ?? "")
        _date = State(initialValue: editing?.date ?? Date())
        _selectedCategoryID = State(initialValue: editing?.category?.id)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isSaving) {
                if case .form(let form) = vm.state {
                    formView(form)
                } else if case .error(let message) = vm.state {
                    errorView(message)
                } else {
                    Color.clear
                }
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
                        clearFieldFocus()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if case .form(let form) = vm.state {
                    PrimaryButton(action: { vm.trigger(.saveTapped) }) {
                        Text(form.isEditMode ? "WORDING_SAVE".localized : "WORDING_ADD".localized)
                    }
                    .disabled(!form.canSave)
                    .padding(.horizontal, Spacing.Semantic.screenMargin)
                    .padding(.vertical, Spacing.Semantic.componentMargin)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onAppear { vm.trigger(.onAppear) }
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

    private var navigationTitle: String {
        if case .form(let form) = vm.state, form.isEditMode {
            return "ADD_EXPENSE.EDIT_TITLE".localized
        }
        return "ADD_EXPENSE".localized
    }

    private func clearFieldFocus() {
        isTitleFocused = false
        isDetailsFocused = false
        isAmountFocused = false
    }

    private func formView(_ form: AddExpenseViewState.FormState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.Semantic.sectionSpacing) {
                AppTextField(
                    title: LocalizedStringKey("ADD_EXPENSE.TITLE"),
                    placeholder: LocalizedStringKey("ADD_EXPENSE.TITLE.PLACEHOLDER"),
                    text: $title,
                    focus: $isTitleFocused,
                    submitLabel: .next,
                    onSubmit: { isDetailsFocused = true }
                )
                .onValueChange(of: title) { vm.trigger(.titleChanged($0)) }

                AppTextField(
                    title: LocalizedStringKey("ADD_EXPENSE.DESCRIPTION"),
                    placeholder: LocalizedStringKey("ADD_EXPENSE.DESCRIPTION.PLACEHOLDER"),
                    text: $details,
                    focus: $isDetailsFocused,
                    submitLabel: .next,
                    onSubmit: { isAmountFocused = true }
                )
                .onValueChange(of: details) { vm.trigger(.detailsChanged($0)) }

                amountField(error: form.amountError)

                dateField

                categoryField(categories: form.categories)
            }
            .padding(.horizontal, Spacing.Semantic.screenMargin)
            .padding(.top, Spacing.Semantic.sectionSpacing)
            .padding(.bottom, Spacing.Semantic.buttonHeightLarge)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func amountField(error: String?) -> some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.componentMargin) {
            Text("ADD_EXPENSE.PRICE".localized)
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

            HStack(spacing: Spacing.Semantic.groupSpacing) {
                Text(Money.currencySymbol(for: currencyCode))
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                TextField("ADD_EXPENSE.PRICE.PLACEHOLDER".localized, text: $amount)
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

    private var dateField: some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.componentMargin) {
            Text("ADD_EXPENSE.DATE".localized)
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.graphical)
                .tint(SemanticColor.Colors.primary.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onValueChange(of: date) { vm.trigger(.dateChanged($0)) }
        }
    }

    private func categoryField(categories: [ExpenseCategory]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.componentMargin) {
            Text("ADD_EXPENSE.CATEGORY".localized)
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

            Picker("ADD_EXPENSE.CATEGORY_PLACEHOLDER".localized, selection: $selectedCategoryID) {
                Text("WORDING_NONE".localized).tag(UUID?.none)
                ForEach(categories) { category in
                    Text(category.name).tag(UUID?.some(category.id))
                }
            }
            .pickerStyle(.menu)
            .tint(SemanticColor.Colors.primary.swiftUIColor)
            .onValueChange(of: selectedCategoryID) { id in
                vm.trigger(.categorySelected(categories.first { $0.id == id }))
            }
        }
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
