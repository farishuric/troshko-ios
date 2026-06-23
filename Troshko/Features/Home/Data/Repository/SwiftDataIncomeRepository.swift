import Foundation
import SwiftData

final class SwiftDataIncomeRepository: IncomeRepository {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetchIncomeEntries() async throws -> [IncomeEntry] {
        let container = container
        return try await MainActor.run {
            let descriptor = FetchDescriptor<IncomeEntryEntity>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try container.mainContext.fetch(descriptor).map { $0.toDomain() }
        }
    }

    func addIncomeEntry(_ entry: IncomeEntry) async throws {
        let container = container
        try await MainActor.run {
            let entity = IncomeEntryEntity(
                id: entry.id,
                source: entry.source,
                amountMinor: entry.amount.amountMinor,
                currencyCode: entry.amount.currencyCode,
                date: entry.date,
                createdAt: entry.createdAt
            )
            container.mainContext.insert(entity)
            try container.mainContext.save()
        }
    }
}
