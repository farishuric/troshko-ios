import DI
import Foundation

protocol SetAppearanceUseCase {
    func execute(_ appearance: AppAppearance)
}

final class StandardSetAppearanceUseCase: SetAppearanceUseCase {
    @Injected private var repository: AppearanceRepository

    func execute(_ appearance: AppAppearance) {
        repository.setAppearance(appearance)
    }
}
