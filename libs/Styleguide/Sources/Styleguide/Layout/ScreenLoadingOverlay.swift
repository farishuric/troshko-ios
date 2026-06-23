import SwiftUI

/// The view `BaseScreen` shows while a screen is loading.
///
/// Styleguide deliberately knows nothing about Lottie: the design-system
/// package stays dependency-light and the app injects a concrete loading
/// visual at its root via `.environment(\.screenLoadingOverlay, …)`. When no
/// override is supplied, a plain `ProgressView` is used so previews and any
/// non-app consumer still render something sensible.
public struct ScreenLoadingOverlayKey: EnvironmentKey {
    public static let defaultValue = AnyView(ProgressView())
}

public extension EnvironmentValues {
    var screenLoadingOverlay: AnyView {
        get { self[ScreenLoadingOverlayKey.self] }
        set { self[ScreenLoadingOverlayKey.self] = newValue }
    }
}
