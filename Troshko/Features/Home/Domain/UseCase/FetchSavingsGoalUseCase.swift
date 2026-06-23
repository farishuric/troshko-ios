import Foundation
import DI

protocol FetchSavingsGoalUseCase {
    func execute() async throws -> SavingsGoal?
}

final class StandardFetchSavingsGoalUseCase: FetchSavingsGoalUseCase {
    @Injected private var repository: SavingsGoalRepository

    func execute() async throws -> SavingsGoal? {
        try await repository.fetchActiveGoal()
    }
}
