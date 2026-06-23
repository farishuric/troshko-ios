enum AppAppearance: String, CaseIterable, Identifiable, Equatable {
    case system
    case light
    case dark

    static let storageKey = "settings.appearance"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .system: return "SETTINGS.APPEARANCE.SYSTEM".localized
        case .light: return "SETTINGS.APPEARANCE.LIGHT".localized
        case .dark: return "SETTINGS.APPEARANCE.DARK".localized
        }
    }

    var systemImageName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

}
