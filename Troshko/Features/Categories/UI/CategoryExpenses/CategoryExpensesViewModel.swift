import Combine
import Foundation
import DI
import MVVM

final class CategoryExpensesViewModel: ViewModel {
    @Published private(set) var state: CategoryExpensesViewState = .loading

    private let eventSubject = PassthroughSubject<EmptyViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<EmptyViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getCategoryExpenses: GetCategoryExpensesUseCase

    private let category: ExpenseCategory

    init(category: ExpenseCategory) {
        self.category = category
    }

    func trigger(_ event: CategoryExpensesViewEvent) {
        switch event {
        case .onAppear, .reload:
            load()
        }
    }

    private func load() {
        Task { @MainActor in
            do {
                let expenses = try await getCategoryExpenses.execute(categoryID: category.id)
                // Reuse the Expenses feature's date-grouping (Today / This month / Month Year).
                state = expenses.isEmpty ? .empty : .loaded(groups: ExpensesViewModel.group(expenses))
            } catch {
                state = .error("EXPENSES.LOAD_ERROR".localized)
            }
        }
    }
}
