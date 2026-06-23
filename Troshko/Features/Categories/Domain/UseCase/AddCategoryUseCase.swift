import Foundation
import DI

protocol AddCategoryUseCase {
    func execute(name: String) async throws
}

final class StandardAddCategoryUseCase: AddCategoryUseCase {
    @Injected private var repository: CategoryRepository

    func execute(name: String) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try await repository.addCategory(name: trimmed)
    }
}
