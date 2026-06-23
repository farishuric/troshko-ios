import Combine
import Foundation
import DI
import MVVM

final class HomeViewModel: ViewModel {
    @Published private(set) var state: HomeViewState = .loading

    private let eventSubject = PassthroughSubject<HomeViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<HomeViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getHomeSummary: GetHomeSummaryUseCase

    func trigger(_ event: HomeViewEvent) {
        switch event {
        case .onAppear, .reload:
            load()
        case .addIncomeTapped:
            eventSubject.send(.presentAddIncome)
        case .savingsGoalTapped:
            eventSubject.send(.presentSavingsGoal(currentGoal))
        }
    }

    private var currentGoal: SavingsGoal? {
        guard case .loaded(let loaded) = state else { return nil }
        return loaded.summary.savingsGoal
    }

    private func load() {
        Task { @MainActor in
            state = .loading
            do {
                let summary = try await getHomeSummary.execute(for: Date())
                state = .loaded(HomeLoadedState(summary: summary))
            } catch {
                state = .error("HOME.LOAD_ERROR".localized)
            }
        }
    }
}
