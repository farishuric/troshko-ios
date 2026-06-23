import Foundation

protocol SavingsGoalRepository {
    func fetchActiveGoal() async throws -> SavingsGoal?
    func upsertGoal(_ goal: SavingsGoal) async throws
}
