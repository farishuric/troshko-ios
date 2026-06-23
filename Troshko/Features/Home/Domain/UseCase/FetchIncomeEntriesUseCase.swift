import Foundation
import DI

protocol FetchIncomeEntriesUseCase {
    func execute() async throws -> [IncomeEntry]
}

final class StandardFetchIncomeEntriesUseCase: FetchIncomeEntriesUseCase {
    @Injected private var repository: IncomeRepository

    func execute() async throws -> [IncomeEntry] {
        try await repository.fetchIncomeEntries()
    }
}
