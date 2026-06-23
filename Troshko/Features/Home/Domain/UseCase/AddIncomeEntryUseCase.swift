import Foundation
import DI

protocol AddIncomeEntryUseCase {
    func execute(_ entry: IncomeEntry) async throws
}

final class StandardAddIncomeEntryUseCase: AddIncomeEntryUseCase {
    @Injected private var repository: IncomeRepository

    func execute(_ entry: IncomeEntry) async throws {
        try await repository.addIncomeEntry(entry)
    }
}
