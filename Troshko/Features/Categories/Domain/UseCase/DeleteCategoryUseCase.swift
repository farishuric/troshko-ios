import Foundation
import DI

protocol DeleteCategoryUseCase {
    func execute(id: UUID) async throws
}

final class StandardDeleteCategoryUseCase: DeleteCategoryUseCase {
    @Injected private var repository: CategoryRepository

    func execute(id: UUID) async throws {
        try await repository.deleteCategory(id: id)
    }
}
