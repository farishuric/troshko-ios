import UIKit
import SwiftUI

public enum SemanticColor {
    public enum Colors {
        public static let accent = ColorAsset(name: "Accent")
        public static let backgroundOverlay = ColorAsset(name: "BackgroundOverlay")
        public static let backgroundPrimary = ColorAsset(name: "BackgroundPrimary")
        public static let backgroundSecondary = ColorAsset(name: "BackgroundSecondary")
        public static let backgroundTertiary = ColorAsset(name: "BackgroundTertiary")
        public static let borderError = ColorAsset(name: "BorderError")
        public static let borderFocus = ColorAsset(name: "BorderFocus")
        public static let borderPrimary = ColorAsset(name: "BorderPrimary")
        public static let borderSecondary = ColorAsset(name: "BorderSecondary")
        public static let buttonDestructive = ColorAsset(name: "ButtonDestructive")
        public static let buttonDisabled = ColorAsset(name: "ButtonDisabled")
        public static let buttonPrimary = ColorAsset(name: "ButtonPrimary")
        public static let buttonSecondary = ColorAsset(name: "ButtonSecondary")
        public static let buttonTertiary = ColorAsset(name: "ButtonTertiary")
        public static let error = ColorAsset(name: "Error")
        public static let heartRate = ColorAsset(name: "HeartRate")
        public static let info = ColorAsset(name: "Info")
        public static let primary = ColorAsset(name: "Primary")
        public static let secondary = ColorAsset(name: "Secondary")
        public static let success = ColorAsset(name: "Success")
        public static let plainWhite = ColorAsset(name: "PlainWhite")
        public static let textError = ColorAsset(name: "TextError")
        public static let textInfo = ColorAsset(name: "TextInfo")
        public static let textInverse = ColorAsset(name: "TextInverse")
        public static let textPrimary = ColorAsset(name: "TextPrimary")
        public static let textSecondary = ColorAsset(name: "TextSecondary")
        public static let textSuccess = ColorAsset(name: "TextSuccess")
        public static let textTertiary = ColorAsset(name: "TextTertiary")
        public static let textWarning = ColorAsset(name: "TextWarning")
        public static let warning = ColorAsset(name: "Warning")
        // Soft floating wellness surfaces & ambient layers
        public static let surfaceCard = ColorAsset(name: "SurfaceCard")
        public static let ambientGlowCyan = ColorAsset(name: "AmbientGlowCyan")
        public static let ambientGlowBlue = ColorAsset(name: "AmbientGlowBlue")
        public static let heartSurface = ColorAsset(name: "HeartSurface")
        public static let wearableCTAStart = ColorAsset(name: "WearableCTAStart")
        public static let wearableCTAMid = ColorAsset(name: "WearableCTAMid")
        public static let wearableCTAEnd = ColorAsset(name: "WearableCTAEnd")

        public static let listBackground = ColorAsset(name: "ListBackground")
        public static let listRow = ColorAsset(name: "ListRow")
        public static let textFieldBG = ColorAsset(name: "TextFieldBG")
        public static let textFieldText = ColorAsset(name: "TextFieldText")
        public static let textFieldPlaceholder = ColorAsset(name: "TextFieldPlaceholder")
    }
}

public final class ColorAsset {
    public fileprivate(set) var name: String

    public typealias Color = UIColor

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    public private(set) lazy var color: Color = {
        guard let color = Color(asset: self) else {
            fatalError("Unable to load color asset named \(name).")
        }
        return color
    }()

    @available(iOS 11.0, tvOS 11.0, *)
    public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
        guard let color = Color(named: name, in: Bundle.module, compatibleWith: traitCollection) else {
            fatalError("Unable to load color asset named \(name).")
        }
        return color
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public private(set) lazy var swiftUIColor: SwiftUI.Color = .init(asset: self)

    fileprivate init(name: String) {
        self.name = name
    }
}

public extension ColorAsset.Color {
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    convenience init?(asset: ColorAsset) {
        self.init(named: asset.name, in: Bundle.module, compatibleWith: nil)
    }
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Color {
    init(asset: ColorAsset) {
        self.init(asset.name, bundle: Bundle.module)
    }
}
