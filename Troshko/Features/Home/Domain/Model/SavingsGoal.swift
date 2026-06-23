import Foundation

struct SavingsGoal: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var targetAmount: Money
    var monthlyTarget: Money
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Money,
        monthlyTarget: Money,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.monthlyTarget = monthlyTarget
        self.createdAt = createdAt
    }
}
