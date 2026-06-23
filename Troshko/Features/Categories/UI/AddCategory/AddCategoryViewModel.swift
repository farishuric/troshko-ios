import Combine
import Foundation
import DI
import MVVM

final class AddCategoryViewModel: ViewModel {
    @Published private(set) var state: AddCategoryViewState = .form(canSave: false)

    private let eventSubject = PassthroughSubject<AddCategoryViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<AddCategoryViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var addCategory: AddCategoryUseCase

    private var name: String = ""

    func trigger(_ event: AddCategoryViewEvent) {
        switch event {
        case .nameChanged(let value):
            name = value
            state = .form(canSave: !trimmedName.isEmpty)
        case .saveTapped:
            save()
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        let name = trimmedName
        guard !name.isEmpty else { return }
        Task { @MainActor in
            state = .saving
            do {
                try await addCategory.execute(name: name)
                eventSubject.send(.saved)
            } catch {
                state = .error("CATEGORIES.SAVE_ERROR".localized)
            }
        }
    }
}
