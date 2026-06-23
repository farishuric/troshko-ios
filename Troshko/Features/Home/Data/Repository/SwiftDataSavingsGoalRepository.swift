import Foundation
import SwiftData

final class SwiftDataSavingsGoalRepository: SavingsGoalRepository {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetchActiveGoal() async throws -> SavingsGoal? {
        let container = container
        return try await MainActor.run {
            var descriptor = FetchDescriptor<SavingsGoalEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            return try container.mainContext.fetch(descriptor).first?.toDomain()
        }
    }

    func upsertGoal(_ goal: SavingsGoal) async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            let entity = try Self.goalEntity(id: goal.id, in: context) ?? Self.firstGoalEntity(in: context)

            if let entity {
                entity.name = goal.name
                entity.targetAmountMinor = goal.targetAmount.amountMinor
                entity.targetCurrencyCode = goal.targetAmount.currencyCode
                entity.monthlyTargetMinor = goal.monthlyTarget.amountMinor
                entity.monthlyTargetCurrencyCode = goal.monthlyTarget.currencyCode
            } else {
                context.insert(SavingsGoalEntity(
                    id: goal.id,
                    name: goal.name,
                    targetAmountMinor: goal.targetAmount.amountMinor,
                    targetCurrencyCode: goal.targetAmount.currencyCode,
                    monthlyTargetMinor: goal.monthlyTarget.amountMinor,
                    monthlyTargetCurrencyCode: goal.monthlyTarget.currencyCode,
                    createdAt: goal.createdAt
                ))
            }

            try context.save()
        }
    }

    @MainActor
    private static func goalEntity(id: UUID, in context: ModelContext) throws -> SavingsGoalEntity? {
        var descriptor = FetchDescriptor<SavingsGoalEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private static func firstGoalEntity(in context: ModelContext) throws -> SavingsGoalEntity? {
        var descriptor = FetchDescriptor<SavingsGoalEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
