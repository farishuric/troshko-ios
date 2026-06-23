import SwiftUI

private struct OpenSettingsEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var openSettings: () -> Void {
        get { self[OpenSettingsEnvironmentKey.self] }
        set { self[OpenSettingsEnvironmentKey.self] = newValue }
    }
}
