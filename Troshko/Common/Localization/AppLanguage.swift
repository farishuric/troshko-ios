import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Equatable {
    case english = "en"
    case bosnian = "bs-BA"
    case german = "de"
    case french = "fr"
    case italian = "it"
    case spanish = "es"

    static let storageKey = "settings.language"
    static let fallback = AppLanguage.english

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .english: return "SETTINGS.LANGUAGE.ENGLISH".localized
        case .bosnian: return "SETTINGS.LANGUAGE.BOSNIAN".localized
        case .german: return "SETTINGS.LANGUAGE.GERMAN".localized
        case .french: return "SETTINGS.LANGUAGE.FRENCH".localized
        case .italian: return "SETTINGS.LANGUAGE.ITALIAN".localized
        case .spanish: return "SETTINGS.LANGUAGE.SPANISH".localized
        }
    }

    var nativeTitle: String {
        switch self {
        case .english: return "English"
        case .bosnian: return "Bosanski"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .italian: return "Italiano"
        case .spanish: return "Español"
        }
    }

    var flagAssetName: String {
        switch self {
        case .english: return "united states"
        case .bosnian: return "bosnia & herzegovina"
        case .german: return "germany"
        case .french: return "france"
        case .italian: return "italy"
        case .spanish: return "spain"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            guard self != AppLanguage.fallback else { return .main }
            return AppLanguage.fallback.bundle
        }
        return bundle
    }

    static var current: AppLanguage {
        guard let rawValue = UserDefaults.standard.string(forKey: storageKey),
              let language = AppLanguage(rawValue: rawValue) else {
            return fallback
        }
        return language
    }
}
