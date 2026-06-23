import Combine
import Foundation
import DI
import MVVM

final class AddIncomeViewModel: ViewModel {
    @Published private(set) var state: AddIncomeViewState = .form(.init(canSave: false, amountError: nil))

    private let eventSubject = PassthroughSubject<AddIncomeViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<AddIncomeViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var addIncomeEntry: AddIncomeEntryUseCase

    private let currencyCode = Money.deviceCurrencyCode
    private var source = ""
    private var amountText = ""
    private var date = Date()

    func trigger(_ event: AddIncomeViewEvent) {
        switch event {
        case .sourceChanged(let value):
            source = value
            refreshForm()
        case .amountChanged(let value):
            amountText = value
            refreshForm()
        case .dateChanged(let value):
            date = value
        case .saveTapped:
            save()
        }
    }

    private var trimmedSource: String {
        source.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func refreshForm() {
        let amount = Money.parse(amountText, currencyCode: currencyCode)
        let amountError: String? = amountText.isEmpty
            ? nil
            : (amount == nil ? "HOME.INCOME.AMOUNT_ERROR".localized : nil)
        state = .form(.init(
            canSave: !trimmedSource.isEmpty && (amount?.amountMinor ?? 0) > 0,
            amountError: amountError
        ))
    }

    private func save() {
        guard
            let amount = Money.parse(amountText, currencyCode: currencyCode),
            amount.amountMinor > 0,
            !trimmedSource.isEmpty
        else { return }

        Task { @MainActor in
            state = .saving
            do {
                try await addIncomeEntry.execute(IncomeEntry(
                    source: trimmedSource,
                    amount: amount,
                    date: date
                ))
                eventSubject.send(.saved)
            } catch {
                state = .error("HOME.INCOME.SAVE_ERROR".localized)
            }
        }
    }
}
