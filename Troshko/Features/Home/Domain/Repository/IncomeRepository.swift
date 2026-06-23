import Foundation

protocol IncomeRepository {
    func fetchIncomeEntries() async throws -> [IncomeEntry]
    func addIncomeEntry(_ entry: IncomeEntry) async throws
}
