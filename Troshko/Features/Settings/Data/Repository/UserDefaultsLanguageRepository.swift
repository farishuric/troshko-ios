import Foundation

final class UserDefaultsLanguageRepository: LanguageRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getLanguage() -> AppLanguage {
        guard let rawValue = userDefaults.string(forKey: AppLanguage.storageKey),
              let language = AppLanguage(rawValue: rawValue) else {
            return .fallback
        }
        return language
    }

    func setLanguage(_ language: AppLanguage) {
        userDefaults.set(language.rawValue, forKey: AppLanguage.storageKey)
    }
}
