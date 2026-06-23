import Foundation
import SwiftData

@Model
final class IncomeEntryEntity {
    @Attribute(.unique) var id: UUID
    var source: String
    var amountMinor: Int
    var currencyCode: String
    var date: Date
    var createdAt: Date

    init(
        id: UUID,
        source: String,
        amountMinor: Int,
        currencyCode: String,
        date: Date,
        createdAt: Date
    ) {
        self.id = id
        self.source = source
        self.amountMinor = amountMinor
        self.currencyCode = currencyCode
        self.date = date
        self.createdAt = createdAt
    }
}

@Model
final class SavingsGoalEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetAmountMinor: Int
    var targetCurrencyCode: String
    var monthlyTargetMinor: Int
    var monthlyTargetCurrencyCode: String
    var createdAt: Date

    init(
        id: UUID,
        name: String,
        targetAmountMinor: Int,
        targetCurrencyCode: String,
        monthlyTargetMinor: Int,
        monthlyTargetCurrencyCode: String,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.targetAmountMinor = targetAmountMinor
        self.targetCurrencyCode = targetCurrencyCode
        self.monthlyTargetMinor = monthlyTargetMinor
        self.monthlyTargetCurrencyCode = monthlyTargetCurrencyCode
        self.createdAt = createdAt
    }
}

extension IncomeEntryEntity {
    func toDomain() -> IncomeEntry {
        IncomeEntry(
            id: id,
            source: source,
            amount: Money(amountMinor: amountMinor, currencyCode: currencyCode),
            date: date,
            createdAt: createdAt
        )
    }
}

extension SavingsGoalEntity {
    func toDomain() -> SavingsGoal {
        SavingsGoal(
            id: id,
            name: name,
            targetAmount: Money(amountMinor: targetAmountMinor, currencyCode: targetCurrencyCode),
            monthlyTarget: Money(amountMinor: monthlyTargetMinor, currencyCode: monthlyTargetCurrencyCode),
            createdAt: createdAt
        )
    }
}
