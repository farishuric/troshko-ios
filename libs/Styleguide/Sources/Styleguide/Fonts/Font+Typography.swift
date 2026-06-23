import SwiftUI

// MARK: - AppFont

/// Central namespace for the PlusJakartaSans type system.
/// Use via the `Font` extension: `.semibold(.large)`, `.regular(.body)`, etc.
public enum AppFont {

    // MARK: - Size

    /// Semantic size tokens mapped to the 8-pt grid.
    public enum Size: CGFloat, CaseIterable {
        case extraSmall = 10
        case small    = 12
        case medium   = 14
        case body     = 16
        case large    = 18
        case title    = 24
        case headline = 32
    }

    // MARK: - Weight

    public enum Weight: CaseIterable {
        case extraLight
        case light
        case regular
        case medium
        case semibold
        case bold
        case extraBold

        var fontName: String {
            switch self {
            case .extraLight: return "PlusJakartaSans-ExtraLight"
            case .light:      return "PlusJakartaSans-Light"
            case .regular:    return "PlusJakartaSans-Regular"
            case .medium:     return "PlusJakartaSans-Medium"
            case .semibold:   return "PlusJakartaSans-SemiBold"
            case .bold:       return "PlusJakartaSans-Bold"
            case .extraBold:  return "PlusJakartaSans-ExtraBold"
            }
        }

        var italicFontName: String {
            switch self {
            case .extraLight: return "PlusJakartaSans-ExtraLightItalic"
            case .light:      return "PlusJakartaSans-LightItalic"
            case .regular:    return "PlusJakartaSans-Italic"
            case .medium:     return "PlusJakartaSans-MediumItalic"
            case .semibold:   return "PlusJakartaSans-SemiBoldItalic"
            case .bold:       return "PlusJakartaSans-BoldItalic"
            case .extraBold:  return "PlusJakartaSans-ExtraBoldItalic"
            }
        }
    }

    // MARK: - Factory

    public static func font(_ weight: Weight, _ size: Size, italic: Bool = false) -> Font {
        let name = italic ? weight.italicFontName : weight.fontName
        return .custom(name, size: size.rawValue)
    }
}

// MARK: - Font extension

public extension Font {

    // MARK: Standard weights

    static func extraLight(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.extraLight, size, italic: italic)
    }

    static func light(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.light, size, italic: italic)
    }

    static func regular(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.regular, size, italic: italic)
    }

    static func medium(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.medium, size, italic: italic)
    }

    static func semibold(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.semibold, size, italic: italic)
    }

    static func bold(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.bold, size, italic: italic)
    }

    static func extraBold(_ size: AppFont.Size, italic: Bool = false) -> Font {
        AppFont.font(.extraBold, size, italic: italic)
    }
}
