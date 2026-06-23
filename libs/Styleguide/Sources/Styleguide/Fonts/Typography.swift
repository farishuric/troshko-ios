import UIKit

// MARK: - Font Name Constants

private enum PlusJakartaSans {
    static let regular        = "PlusJakartaSans-Regular"
    static let medium         = "PlusJakartaSans-Medium"
    static let semiBold       = "PlusJakartaSans-SemiBold"
    static let bold           = "PlusJakartaSans-Bold"
    static let light          = "PlusJakartaSans-Light"
    static let extraLight     = "PlusJakartaSans-ExtraLight"
    static let extraBold      = "PlusJakartaSans-ExtraBold"
    static let italic         = "PlusJakartaSans-Italic"
    static let mediumItalic   = "PlusJakartaSans-MediumItalic"
    static let semiBoldItalic = "PlusJakartaSans-SemiBoldItalic"
    static let boldItalic     = "PlusJakartaSans-BoldItalic"
    static let lightItalic    = "PlusJakartaSans-LightItalic"
    static let extraBoldItalic = "PlusJakartaSans-ExtraBoldItalic"

    static func font(_ name: String, size: CGFloat) -> UIFont {
        UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }
}

// MARK: - Typography Configuration

public struct TypographyConfig {
    public let font: UIFont
    public let lineHeight: CGFloat
    public let letterSpacing: CGFloat
}

// MARK: - Typography

public enum Typography {
    // MARK: - Display Styles

    public static let display = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.bold, size: 40),
        lineHeight: 48,
        letterSpacing: -0.5
    )

    public static let headline = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.bold, size: 32),
        lineHeight: 40,
        letterSpacing: -0.3
    )

    // MARK: - Title Styles

    public static let titleLarge = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.semiBold, size: 28),
        lineHeight: 36,
        letterSpacing: -0.2
    )

    public static let title = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.semiBold, size: 24),
        lineHeight: 32,
        letterSpacing: -0.1
    )

    public static let subtitle = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.medium, size: 20),
        lineHeight: 28,
        letterSpacing: 0
    )

    // MARK: - Body Styles

    public static let bodyLarge = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 18),
        lineHeight: 26,
        letterSpacing: 0
    )

    public static let body = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 16),
        lineHeight: 24,
        letterSpacing: 0
    )

    public static let bodyMedium = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.medium, size: 16),
        lineHeight: 24,
        letterSpacing: 0
    )

    public static let bodySmall = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 14),
        lineHeight: 20,
        letterSpacing: 0
    )

    // MARK: - Caption Styles

    public static let caption = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 12),
        lineHeight: 16,
        letterSpacing: 0.2
    )

    public static let captionMedium = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.medium, size: 12),
        lineHeight: 16,
        letterSpacing: 0.2
    )

    // MARK: - Button Styles

    public static let buttonLarge = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.semiBold, size: 18),
        lineHeight: 24,
        letterSpacing: 0
    )

    public static let button = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.semiBold, size: 16),
        lineHeight: 20,
        letterSpacing: 0
    )

    public static let buttonSmall = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.semiBold, size: 14),
        lineHeight: 18,
        letterSpacing: 0
    )

    // MARK: - Label Styles

    public static let labelLarge = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.medium, size: 16),
        lineHeight: 22,
        letterSpacing: 0
    )

    public static let label = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.medium, size: 14),
        lineHeight: 20,
        letterSpacing: 0
    )

    public static let labelSmall = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.medium, size: 12),
        lineHeight: 16,
        letterSpacing: 0.1
    )

    // MARK: - TextField Styles

    public static let textField = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 16),
        lineHeight: 24,
        letterSpacing: 0
    )

    public static let textFieldLarge = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 18),
        lineHeight: 26,
        letterSpacing: 0
    )

    public static let textFieldSmall = TypographyConfig(
        font: PlusJakartaSans.font(PlusJakartaSans.regular, size: 14),
        lineHeight: 20,
        letterSpacing: 0
    )
}
