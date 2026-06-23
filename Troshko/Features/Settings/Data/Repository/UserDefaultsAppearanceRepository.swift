import Foundation

final class UserDefaultsAppearanceRepository: AppearanceRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getAppearance() -> AppAppearance {
        guard
            let rawValue = userDefaults.string(forKey: AppAppearance.storageKey),
            let appearance = AppAppearance(rawValue: rawValue)
        else {
            return .system
        }

        return appearance
    }

    func setAppearance(_ appearance: AppAppearance) {
        userDefaults.set(appearance.rawValue, forKey: AppAppearance.storageKey)
    }
}
