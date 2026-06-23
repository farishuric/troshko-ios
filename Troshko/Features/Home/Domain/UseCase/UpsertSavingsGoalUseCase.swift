import Foundation
import DI

protocol UpsertSavingsGoalUseCase {
    func execute(_ goal: SavingsGoal) async throws
}

final class StandardUpsertSavingsGoalUseCase: UpsertSavingsGoalUseCase {
    @Injected private var repository: SavingsGoalRepository

    func execute(_ goal: SavingsGoal) async throws {
        try await repository.upsertGoal(goal)
    }
}
