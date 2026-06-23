import Foundation
import MVVM

struct SettingsViewState: ViewState, Equatable {
    var appearance: AppAppearance
    var appVersion: String
    var languageName: String
}
