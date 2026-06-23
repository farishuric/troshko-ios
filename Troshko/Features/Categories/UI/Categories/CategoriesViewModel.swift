import Combine
import Foundation
import DI
import MVVM

final class CategoriesViewModel: ViewModel {
    @Published private(set) var state: CategoriesViewState = .loading

    private let eventSubject = PassthroughSubject<CategoriesViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<CategoriesViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getCategories: GetCategoriesUseCase
    @Injected private var deleteCategory: DeleteCategoryUseCase

    func trigger(_ event: CategoriesViewEvent) {
        switch event {
        case .onAppear, .reload:
            load()
        case .addTapped:
            eventSubject.send(.presentAddCategory)
        case .deleteTapped(let category):
            delete(category)
        }
    }

    private func load() {
        Task { @MainActor in
            do {
                let categories = try await getCategories.execute()
                state = categories.isEmpty ? .empty : .loaded(categories: categories)
            } catch {
                state = .error("CATEGORIES.LOAD_ERROR".localized)
            }
        }
    }

    private func delete(_ category: ExpenseCategory) {
        Task { @MainActor in
            do {
                try await deleteCategory.execute(id: category.id)
                load()
            } catch {
                state = .error("CATEGORIES.DELETE_ERROR".localized)
            }
        }
    }
}
