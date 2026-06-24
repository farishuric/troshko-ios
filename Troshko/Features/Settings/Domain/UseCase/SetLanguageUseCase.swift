import DI
import Foundation

protocol SetLanguageUseCase {
    func execute(_ language: AppLanguage)
}

final class StandardSetLanguageUseCase: SetLanguageUseCase {
    @Injected private var repository: LanguageRepository

    func execute(_ language: AppLanguage) {
        repository.setLanguage(language)
    }
}
