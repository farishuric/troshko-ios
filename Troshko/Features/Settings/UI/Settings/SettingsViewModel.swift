import Combine
import DI
import Foundation
import MVVM

final class SettingsViewModel: ViewModel {
    @Published private(set) var state: SettingsViewState

    private let eventSubject = PassthroughSubject<SettingsViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<SettingsViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getAppearance: GetAppearanceUseCase
    @Injected private var setAppearance: SetAppearanceUseCase

    init() {
        self.state = SettingsViewState(
            appearance: .system,
            appVersion: SettingsViewModel.currentAppVersion(),
            languageName: SettingsViewModel.currentLanguageName()
        )
    }

    func trigger(_ event: SettingsViewEvent) {
        switch event {
        case .onAppear:
            refresh()
        case .appearanceSelected(let appearance):
            setAppearance.execute(appearance)
            state.appearance = appearance
        }
    }

    private func refresh() {
        state = SettingsViewState(
            appearance: getAppearance.execute(),
            appVersion: SettingsViewModel.currentAppVersion(),
            languageName: SettingsViewModel.currentLanguageName()
        )
    }

    private static func currentAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        switch (version, build) {
        case let (version?, build?):
            return "\(version) (\(build))"
        case let (version?, nil):
            return version
        default:
            return "WORDING_UNKNOWN".localized
        }
    }

    private static func currentLanguageName() -> String {
        let identifier = Locale.current.identifier
        return Locale.current.localizedString(forIdentifier: identifier)?.capitalized
            ?? Locale.current.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "")
            ?? identifier
    }
}
