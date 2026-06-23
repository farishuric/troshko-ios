import Combine
import Foundation
import DI
import MVVM

final class MonthlyOverviewViewModel: ViewModel {
    @Published private(set) var state: MonthlyOverviewViewState = .loading

    private let eventSubject = PassthroughSubject<EmptyViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<EmptyViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getOverview: GetMonthlyOverviewUseCase

    func trigger(_ event: MonthlyOverviewViewEvent) {
        switch event {
        case .load(let date):
            load(for: date)
        }
    }

    private func load(for date: Date) {
        Task { @MainActor in
            do {
                let items = try await getOverview.execute(for: date)
                let currencyCode = items.first?.total.currencyCode ?? Money.deviceCurrencyCode
                let total = items.reduce(.zero(currencyCode: currencyCode)) { $0 + $1.total }
                state = items.isEmpty ? .empty : .loaded(items: items, total: total)
            } catch {
                state = .error("MONTHLY_OVERVIEW.LOAD_ERROR".localized)
            }
        }
    }
}
