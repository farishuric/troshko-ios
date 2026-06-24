import DI
import Foundation

enum SettingsDependencyContainer {
    static func register() {
        DIContainer.shared.register(
            UserDefaultsAppearanceRepository() as AppearanceRepository,
            as: AppearanceRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            UserDefaultsLanguageRepository() as LanguageRepository,
            as: LanguageRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetAppearanceUseCase() as GetAppearanceUseCase,
            as: GetAppearanceUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardSetAppearanceUseCase() as SetAppearanceUseCase,
            as: SetAppearanceUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetLanguageUseCase() as GetLanguageUseCase,
            as: GetLanguageUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardSetLanguageUseCase() as SetLanguageUseCase,
            as: SetLanguageUseCase.self,
            configuration: .shared
        )
    }
}
