import Combine
import Foundation
import DI
import MVVM

final class ExpensesViewModel: ViewModel {
    @Published private(set) var state: ExpensesViewState = .loading

    private let eventSubject = PassthroughSubject<ExpensesViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<ExpensesViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getExpenses: GetExpensesUseCase
    @Injected private var deleteExpense: DeleteExpenseUseCase

    func trigger(_ event: ExpensesViewEvent) {
        switch event {
        case .onAppear, .reload:
            load()
        case .addTapped:
            eventSubject.send(.presentAddExpense)
        case .editTapped(let expense):
            eventSubject.send(.presentEditExpense(expense))
        case .deleteTapped(let expense):
            delete(expense)
        }
    }

    private func load() {
        Task { @MainActor in
            do {
                let expenses = try await getExpenses.execute()
                state = expenses.isEmpty
                    ? .empty
                    : .loaded(groups: Self.group(expenses))
            } catch {
                state = .error("EXPENSES.LOAD_ERROR".localized)
            }
        }
    }

    private func delete(_ expense: Expense) {
        Task { @MainActor in
            do {
                try await deleteExpense.execute(id: expense.id)
                load()
            } catch {
                state = .error("EXPENSES.DELETE_ERROR".localized)
            }
        }
    }

    // MARK: - Grouping

    /// Groups expenses (already sorted newest-first) under Today / This month / "Month Year"
    /// headings, preserving the original app's behaviour.
    static func group(_ expenses: [Expense]) -> [ExpenseGroup] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMMM yyyy"
        monthYearFormatter.locale = AppLanguage.current.locale

        var order: [String] = []
        var buckets: [String: ExpenseGroup] = [:]

        for expense in expenses {
            let date = expense.date
            let key: String
            let title: String

            if calendar.isDate(date, inSameDayAs: now) {
                key = "today"
                title = "CALENDAR_TODAY".localized
            } else if calendar.component(.month, from: date) == currentMonth,
                      calendar.component(.year, from: date) == currentYear {
                key = "thisMonth"
                title = "CALENDAR_THIS_MONTH".localized
            } else {
                title = monthYearFormatter.string(from: date)
                key = title
            }

            if let existing = buckets[key] {
                buckets[key] = ExpenseGroup(id: key, title: title, expenses: existing.expenses + [expense])
            } else {
                order.append(key)
                buckets[key] = ExpenseGroup(id: key, title: title, expenses: [expense])
            }
        }

        return order.compactMap { buckets[$0] }
    }
}
