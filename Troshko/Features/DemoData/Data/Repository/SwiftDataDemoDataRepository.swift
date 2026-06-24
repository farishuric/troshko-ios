import Foundation
import SwiftData

final class SwiftDataDemoDataRepository: DemoDataRepository {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func seedDemoData() async throws {
        let container = container
        try await MainActor.run {
            let context = container.mainContext
            let calendar = Calendar.current
            let currencyCode = Money.deviceCurrencyCode
            let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
            let createdAt = calendar.date(
                byAdding: .month,
                value: -DemoDataConfiguration.monthCount,
                to: monthStart
            ) ?? monthStart

            let categories = try seedCategories(in: context, createdAt: createdAt)
            try seedIncome(
                in: context,
                calendar: calendar,
                monthStart: monthStart,
                currencyCode: currencyCode
            )
            try seedExpenses(
                in: context,
                calendar: calendar,
                monthStart: monthStart,
                currencyCode: currencyCode,
                categories: categories
            )
            try seedSavingsGoalIfNeeded(in: context, createdAt: createdAt, currencyCode: currencyCode)
            try context.save()
        }
    }

    @MainActor
    private func seedCategories(
        in context: ModelContext,
        createdAt: Date
    ) throws -> [DemoCategory: ExpenseCategoryEntity] {
        var entities: [DemoCategory: ExpenseCategoryEntity] = [:]

        for category in DemoCategory.allCases {
            if let existing = try categoryEntity(id: category.id, in: context) {
                entities[category] = existing
                continue
            }

            let entity = ExpenseCategoryEntity(
                id: category.id,
                name: category.displayName,
                createdAt: createdAt
            )
            context.insert(entity)
            entities[category] = entity
        }

        return entities
    }

    @MainActor
    private func seedIncome(
        in context: ModelContext,
        calendar: Calendar,
        monthStart: Date,
        currencyCode: String
    ) throws {
        for monthIndex in 0..<DemoDataConfiguration.monthCount {
            let monthOffset = monthIndex - (DemoDataConfiguration.monthCount - 1)
            let month = calendar.date(byAdding: .month, value: monthOffset, to: monthStart) ?? monthStart
            let identity = monthIdentity(for: month, calendar: calendar)
            let salaryID = demoUUID(kind: 2, year: identity.year, month: identity.month, itemIndex: 1)

            if shouldSeed(day: 1, monthIndex: monthIndex, calendar: calendar),
               try incomeEntity(id: salaryID, in: context) == nil {
                context.insert(IncomeEntryEntity(
                    id: salaryID,
                    source: "Demo Salary",
                    amountMinor: incomeAmount(for: monthIndex),
                    currencyCode: currencyCode,
                    date: date(in: month, day: 1, calendar: calendar),
                    createdAt: date(in: month, day: 1, calendar: calendar)
                ))
            }

            let freelanceID = demoUUID(kind: 2, year: identity.year, month: identity.month, itemIndex: 2)
            if monthIndex % 4 == 1,
               shouldSeed(day: 18, monthIndex: monthIndex, calendar: calendar),
               try incomeEntity(id: freelanceID, in: context) == nil {
                context.insert(IncomeEntryEntity(
                    id: freelanceID,
                    source: "Demo Freelance",
                    amountMinor: 28000 + (monthIndex % 5) * 3500,
                    currencyCode: currencyCode,
                    date: date(in: month, day: 18, calendar: calendar),
                    createdAt: date(in: month, day: 18, calendar: calendar)
                ))
            }

            let bonusID = demoUUID(kind: 2, year: identity.year, month: identity.month, itemIndex: 3)
            if monthIndex % 6 == 5,
               shouldSeed(day: 24, monthIndex: monthIndex, calendar: calendar),
               try incomeEntity(id: bonusID, in: context) == nil {
                context.insert(IncomeEntryEntity(
                    id: bonusID,
                    source: "Demo Bonus",
                    amountMinor: 52000 + monthIndex * 600,
                    currencyCode: currencyCode,
                    date: date(in: month, day: 24, calendar: calendar),
                    createdAt: date(in: month, day: 24, calendar: calendar)
                ))
            }
        }
    }

    @MainActor
    private func seedExpenses(
        in context: ModelContext,
        calendar: Calendar,
        monthStart: Date,
        currencyCode: String,
        categories: [DemoCategory: ExpenseCategoryEntity]
    ) throws {
        for monthIndex in 0..<DemoDataConfiguration.monthCount {
            let monthOffset = monthIndex - (DemoDataConfiguration.monthCount - 1)
            let month = calendar.date(byAdding: .month, value: monthOffset, to: monthStart) ?? monthStart
            let identity = monthIdentity(for: month, calendar: calendar)

            for template in expenseTemplates(for: monthIndex) {
                guard shouldSeed(day: template.day, monthIndex: monthIndex, calendar: calendar) else {
                    continue
                }

                let id = demoUUID(
                    kind: 3,
                    year: identity.year,
                    month: identity.month,
                    itemIndex: template.itemIndex
                )
                guard try expenseEntity(id: id, in: context) == nil else { continue }

                context.insert(ExpenseEntity(
                    id: id,
                    title: template.title,
                    details: "Demo data",
                    amountMinor: template.amountMinor,
                    currencyCode: currencyCode,
                    date: date(in: month, day: template.day, calendar: calendar),
                    category: categories[template.category]
                ))
            }
        }
    }

    @MainActor
    private func seedSavingsGoalIfNeeded(
        in context: ModelContext,
        createdAt: Date,
        currencyCode: String
    ) throws {
        let existingGoals = try context.fetch(FetchDescriptor<SavingsGoalEntity>())
        guard existingGoals.isEmpty else { return }

        let id = demoUUID(kind: 4, year: 0, month: 0, itemIndex: 1)
        context.insert(SavingsGoalEntity(
            id: id,
            name: "Demo Emergency fund",
            targetAmountMinor: 650000,
            targetCurrencyCode: currencyCode,
            monthlyTargetMinor: 52000,
            monthlyTargetCurrencyCode: currencyCode,
            createdAt: createdAt
        ))
    }

    @MainActor
    private func categoryEntity(id: UUID, in context: ModelContext) throws -> ExpenseCategoryEntity? {
        var descriptor = FetchDescriptor<ExpenseCategoryEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func incomeEntity(id: UUID, in context: ModelContext) throws -> IncomeEntryEntity? {
        var descriptor = FetchDescriptor<IncomeEntryEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func expenseEntity(id: UUID, in context: ModelContext) throws -> ExpenseEntity? {
        var descriptor = FetchDescriptor<ExpenseEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func date(in month: Date, day: Int, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = day
        components.hour = 12
        return calendar.date(from: components) ?? month
    }

    private func monthIdentity(for month: Date, calendar: Calendar) -> (year: Int, month: Int) {
        let components = calendar.dateComponents([.year, .month], from: month)
        return (components.year ?? 2000, components.month ?? 1)
    }

    private func shouldSeed(day: Int, monthIndex: Int, calendar: Calendar) -> Bool {
        guard monthIndex == DemoDataConfiguration.monthCount - 1 else { return true }
        return day <= calendar.component(.day, from: Date())
    }

    private func demoUUID(kind: Int, year: Int, month: Int, itemIndex: Int) -> UUID {
        let text = String(
            format: "D0D0%04X-%04d-40%02d-8000-%012X",
            kind,
            year,
            month,
            itemIndex
        )
        return UUID(uuidString: text)!
    }

    private func incomeAmount(for monthIndex: Int) -> Int {
        242000 + (monthIndex / 6) * 9000 + (monthIndex % 4) * 1800
    }

    private func expenseTemplates(for monthIndex: Int) -> [ExpenseTemplate] {
        let quarterBump = (monthIndex / 3) * 250
        return [
            ExpenseTemplate(1, "Demo Rent", 92000, 2, .rent),
            ExpenseTemplate(2, "Demo Groceries", 16800 + monthIndex * 380, 4, .groceries),
            ExpenseTemplate(3, "Demo Electricity", 8200 + quarterBump, 5, .utilities),
            ExpenseTemplate(4, "Demo Internet", 3900, 6, .internet),
            ExpenseTemplate(5, "Demo Phone", 2200 + (monthIndex % 3) * 200, 7, .internet),
            ExpenseTemplate(6, "Demo Coffee", 980 + (monthIndex % 5) * 70, 8, .coffee),
            ExpenseTemplate(7, "Demo Bus pass", 4300, 9, .transport),
            ExpenseTemplate(8, "Demo Fuel", 6400 + (monthIndex % 4) * 650, 11, .transport),
            ExpenseTemplate(9, "Demo Lunch", 2450 + (monthIndex % 6) * 110, 12, .dining),
            ExpenseTemplate(10, "Demo Pharmacy", 3100 + (monthIndex % 4) * 240, 14, .health),
            ExpenseTemplate(11, "Demo Gym", 5200, 15, .fitness),
            ExpenseTemplate(12, "Demo Streaming", 1450, 16, .subscriptions),
            ExpenseTemplate(13, "Demo Market refill", 12800 + monthIndex * 290, 18, .groceries),
            ExpenseTemplate(14, "Demo Dinner out", 4600 + (monthIndex % 5) * 430, 20, .dining),
            ExpenseTemplate(15, "Demo Cinema", 2600 + (monthIndex % 3) * 250, 21, .entertainment),
            ExpenseTemplate(16, "Demo Clothes", 7200 + (monthIndex % 6) * 650, 23, .shopping),
            ExpenseTemplate(17, "Demo Home supplies", 3900 + (monthIndex % 5) * 300, 25, .home),
            ExpenseTemplate(18, "Demo Gift", 5200 + (monthIndex % 4) * 450, 26, .gifts),
            ExpenseTemplate(19, "Demo Course", 3400 + (monthIndex % 3) * 500, 27, .education),
            ExpenseTemplate(20, "Demo Weekend trip", 11800 + (monthIndex % 6) * 900, 28, .travel)
        ]
    }
}

private enum DemoCategory: CaseIterable, Hashable {
    case rent
    case groceries
    case utilities
    case coffee
    case transport
    case dining
    case health
    case shopping
    case internet
    case subscriptions
    case entertainment
    case travel
    case education
    case home
    case gifts
    case fitness

    var id: UUID {
        switch self {
        case .rent: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000001")!
        case .groceries: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000002")!
        case .utilities: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000003")!
        case .coffee: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000004")!
        case .transport: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000005")!
        case .dining: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000006")!
        case .health: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000007")!
        case .shopping: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000008")!
        case .internet: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000009")!
        case .subscriptions: return UUID(uuidString: "D0D00001-0000-4000-8000-00000000000A")!
        case .entertainment: return UUID(uuidString: "D0D00001-0000-4000-8000-00000000000B")!
        case .travel: return UUID(uuidString: "D0D00001-0000-4000-8000-00000000000C")!
        case .education: return UUID(uuidString: "D0D00001-0000-4000-8000-00000000000D")!
        case .home: return UUID(uuidString: "D0D00001-0000-4000-8000-00000000000E")!
        case .gifts: return UUID(uuidString: "D0D00001-0000-4000-8000-00000000000F")!
        case .fitness: return UUID(uuidString: "D0D00001-0000-4000-8000-000000000010")!
        }
    }

    var displayName: String {
        switch self {
        case .rent: return "Demo Rent"
        case .groceries: return "Demo Groceries"
        case .utilities: return "Demo Utilities"
        case .coffee: return "Demo Coffee"
        case .transport: return "Demo Transport"
        case .dining: return "Demo Dining"
        case .health: return "Demo Health"
        case .shopping: return "Demo Shopping"
        case .internet: return "Demo Internet"
        case .subscriptions: return "Demo Subscriptions"
        case .entertainment: return "Demo Entertainment"
        case .travel: return "Demo Travel"
        case .education: return "Demo Education"
        case .home: return "Demo Home"
        case .gifts: return "Demo Gifts"
        case .fitness: return "Demo Fitness"
        }
    }
}

private struct ExpenseTemplate {
    let itemIndex: Int
    let title: String
    let amountMinor: Int
    let day: Int
    let category: DemoCategory

    init(
        _ itemIndex: Int,
        _ title: String,
        _ amountMinor: Int,
        _ day: Int,
        _ category: DemoCategory
    ) {
        self.itemIndex = itemIndex
        self.title = title
        self.amountMinor = amountMinor
        self.day = day
        self.category = category
    }
}
