import Combine
import Foundation
import DI
import MVVM

final class AddExpenseViewModel: ViewModel {
    @Published private(set) var state: AddExpenseViewState

    private let eventSubject = PassthroughSubject<AddExpenseViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<AddExpenseViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getCategories: GetExpenseCategoriesUseCase
    @Injected private var addExpense: AddExpenseUseCase
    @Injected private var updateExpense: UpdateExpenseUseCase

    private let editing: Expense?

    private var title: String
    private var details: String
    private var amountText: String
    private var date: Date
    private var selectedCategory: ExpenseCategory?
    private var categories: [ExpenseCategory] = []

    init(editing: Expense?) {
        self.editing = editing
        self.title = editing?.title ?? ""
        self.details = editing?.details ?? ""
        self.amountText = editing.map { Self.amountString($0.amount) } ?? ""
        self.date = editing?.date ?? Date()
        self.selectedCategory = editing?.category
        self.state = .form(.init(categories: [], canSave: false, amountError: nil, isEditMode: editing != nil))
        refreshForm()
    }

    func trigger(_ event: AddExpenseViewEvent) {
        switch event {
        case .onAppear:
            loadCategories()
        case .titleChanged(let value):
            title = value
            refreshForm()
        case .detailsChanged(let value):
            details = value
            refreshForm()
        case .amountChanged(let value):
            amountText = value
            refreshForm()
        case .dateChanged(let value):
            date = value
        case .categorySelected(let category):
            selectedCategory = category
        case .saveTapped:
            save()
        }
    }

    private func loadCategories() {
        Task { @MainActor in
            categories = (try? await getCategories.execute()) ?? []
            refreshForm()
        }
    }

    private func refreshForm() {
        let amount = Self.parseAmount(amountText)
        let amountError: String? = amountText.isEmpty
            ? nil
            : (amount == nil ? "ADD_EXPENSE.PRICE.ERROR".localized : nil)
        let canSave = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (amount ?? 0) > 0
        state = .form(.init(
            categories: categories,
            canSave: canSave,
            amountError: amountError,
            isEditMode: editing != nil
        ))
    }

    private func save() {
        guard
            let amount = Self.parseAmount(amountText), amount > 0,
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        let expense = Expense(
            id: editing?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            date: date,
            category: selectedCategory
        )

        Task { @MainActor in
            state = .saving
            do {
                if editing != nil {
                    try await updateExpense.execute(expense)
                } else {
                    try await addExpense.execute(expense)
                }
                eventSubject.send(.saved)
            } catch {
                state = .error("EXPENSES.SAVE_ERROR".localized)
            }
        }
    }

    // MARK: - Amount formatting

    private static func parseAmount(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return value
    }

    private static func amountString(_ amount: Double) -> String {
        String(format: "%.2f", amount)
    }
}
