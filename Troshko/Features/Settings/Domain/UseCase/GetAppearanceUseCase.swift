import DI
import Foundation

protocol GetAppearanceUseCase {
    func execute() -> AppAppearance
}

final class StandardGetAppearanceUseCase: GetAppearanceUseCase {
    @Injected private var repository: AppearanceRepository

    func execute() -> AppAppearance {
        repository.getAppearance()
    }
}
