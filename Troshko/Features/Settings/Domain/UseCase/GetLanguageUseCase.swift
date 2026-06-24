import DI
import Foundation

protocol GetLanguageUseCase {
    func execute() -> AppLanguage
}

final class StandardGetLanguageUseCase: GetLanguageUseCase {
    @Injected private var repository: LanguageRepository

    func execute() -> AppLanguage {
        repository.getLanguage()
    }
}
