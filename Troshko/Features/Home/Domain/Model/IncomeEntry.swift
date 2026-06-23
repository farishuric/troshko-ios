import Foundation

struct IncomeEntry: Identifiable, Equatable, Hashable {
    let id: UUID
    var source: String
    var amount: Money
    var date: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        source: String,
        amount: Money,
        date: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.amount = amount
        self.date = date
        self.createdAt = createdAt
    }
}
