import Foundation
import MVVM

enum SettingsViewEvent: ViewEvent {
    case onAppear
    case appearanceSelected(AppAppearance)
}
