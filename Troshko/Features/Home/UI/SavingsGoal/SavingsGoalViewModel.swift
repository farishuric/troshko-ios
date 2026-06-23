import Combine
import Foundation
import DI
import MVVM

final class SavingsGoalViewModel: ViewModel {
    @Published private(set) var state: SavingsGoalViewState

    private let eventSubject = PassthroughSubject<SavingsGoalViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<SavingsGoalViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var upsertSavingsGoal: UpsertSavingsGoalUseCase

    private let editing: SavingsGoal?
    private let currencyCode: String
    private var name: String
    private var targetAmountText: String
    private var monthlyTargetText: String

    init(editing: SavingsGoal?) {
        self.editing = editing
        self.currencyCode = editing?.targetAmount.currencyCode ?? Money.deviceCurrencyCode
        self.name = editing?.name ?? ""
        self.targetAmountText = editing?.targetAmount.inputText() ?? ""
        self.monthlyTargetText = editing?.monthlyTarget.inputText() ?? ""
        self.state = .form(.init(
            canSave: false,
            targetAmountError: nil,
            monthlyTargetError: nil,
            isEditMode: editing != nil
        ))
        refreshForm()
    }

    func trigger(_ event: SavingsGoalViewEvent) {
        switch event {
        case .nameChanged(let value):
            name = value
            refreshForm()
        case .targetAmountChanged(let value):
            targetAmountText = value
            refreshForm()
        case .monthlyTargetChanged(let value):
            monthlyTargetText = value
            refreshForm()
        case .saveTapped:
            save()
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func refreshForm() {
        let target = Money.parse(targetAmountText, currencyCode: currencyCode)
        let monthly = Money.parse(monthlyTargetText, currencyCode: currencyCode)
        state = .form(.init(
            canSave: !trimmedName.isEmpty
                && (target?.amountMinor ?? 0) > 0
                && (monthly?.amountMinor ?? 0) > 0,
            targetAmountError: amountError(for: targetAmountText, parsed: target),
            monthlyTargetError: amountError(for: monthlyTargetText, parsed: monthly),
            isEditMode: editing != nil
        ))
    }

    private func amountError(for text: String, parsed: Money?) -> String? {
        text.isEmpty ? nil : (parsed == nil ? "HOME.GOAL.AMOUNT_ERROR".localized : nil)
    }

    private func save() {
        guard
            let target = Money.parse(targetAmountText, currencyCode: currencyCode),
            let monthly = Money.parse(monthlyTargetText, currencyCode: currencyCode),
            target.amountMinor > 0,
            monthly.amountMinor > 0,
            !trimmedName.isEmpty
        else { return }

        let goal = SavingsGoal(
            id: editing?.id ?? UUID(),
            name: trimmedName,
            targetAmount: target,
            monthlyTarget: monthly,
            createdAt: editing?.createdAt ?? Date()
        )

        Task { @MainActor in
            state = .saving
            do {
                try await upsertSavingsGoal.execute(goal)
                eventSubject.send(.saved)
            } catch {
                state = .error("HOME.GOAL.SAVE_ERROR".localized)
            }
        }
    }
}
