import UIKit

public class StyleLabel: UILabel {
    // MARK: - Label Styles

    public enum Style {
        case display
        case headline
        case titleLarge
        case title
        case subtitle
        case bodyLarge
        case body
        case bodyMedium
        case bodySmall
        case caption
        case captionMedium
        case labelLarge
        case label
        case labelSmall
    }

    // MARK: - Properties

    public var labelStyle: Style = .body {
        didSet { updateAppearance() }
    }

    public var textColorStyle: ColorAsset = SemanticColor.Colors.textPrimary {
        didSet { updateAppearance() }
    }

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }

    public convenience init(style: Style, text: String? = nil) {
        self.init(frame: .zero)
        labelStyle = style
        self.text = text
        setupLabel()
    }

    // MARK: - Setup

    private func setupLabel() {
        updateAppearance()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // Typography
        let config = typographyForStyle(labelStyle)
        font = config.font

        // Colors
        textColor = textColorStyle.color

        // Default properties
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
    }

    private func typographyForStyle(_ style: Style) -> TypographyConfig {
        switch style {
        case .display: return Typography.display
        case .headline: return Typography.headline
        case .titleLarge: return Typography.titleLarge
        case .title: return Typography.title
        case .subtitle: return Typography.subtitle
        case .bodyLarge: return Typography.bodyLarge
        case .body: return Typography.body
        case .bodyMedium: return Typography.bodyMedium
        case .bodySmall: return Typography.bodySmall
        case .caption: return Typography.caption
        case .captionMedium: return Typography.captionMedium
        case .labelLarge: return Typography.labelLarge
        case .label: return Typography.label
        case .labelSmall: return Typography.labelSmall
        }
    }

    // MARK: - Public Methods

    public func setStyle(_ style: Style) {
        labelStyle = style
    }

    public func setTextColorStyle(_ colorStyle: ColorAsset) {
        textColorStyle = colorStyle
    }

    public func setText(_ text: String?, style: Style? = nil, colorStyle: ColorAsset? = nil) {
        self.text = text
        if let style = style {
            labelStyle = style
        }
        if let colorStyle = colorStyle {
            textColorStyle = colorStyle
        }
    }

    // MARK: - Convenience Methods

    public static func display(_ text: String) -> StyleLabel {
        return StyleLabel(style: .display, text: text)
    }

    public static func headline(_ text: String) -> StyleLabel {
        return StyleLabel(style: .headline, text: text)
    }

    public static func title(_ text: String) -> StyleLabel {
        return StyleLabel(style: .title, text: text)
    }

    public static func body(_ text: String) -> StyleLabel {
        return StyleLabel(style: .body, text: text)
    }

    public static func caption(_ text: String) -> StyleLabel {
        return StyleLabel(style: .caption, text: text)
    }
}

// MARK: - Preview Builders (Public for Testing)

#if DEBUG
@available(iOS 17.0, *)
public enum StyleLabelPreviews {
    public static func typographyScale() -> UIViewController {
        return PreviewContainer.createScrollable {
            UIStackView.vertical(alignment: .leading) {
                [
                    StyleLabel(style: .display, text: "Display Text"),
                    StyleLabel(style: .headline, text: "Headline Text"),
                    StyleLabel(style: .titleLarge, text: "Large Title"),
                    StyleLabel(style: .title, text: "Standard Title"),
                    StyleLabel(style: .subtitle, text: "Subtitle Text"),
                    StyleLabel(style: .bodyLarge, text: "Large body text for important content"),
                    StyleLabel(style: .body, text: "Standard body text for regular content"),
                    StyleLabel(style: .bodyMedium, text: "Medium weight body text"),
                    StyleLabel(style: .bodySmall, text: "Small body text for secondary content"),
                    StyleLabel(style: .labelLarge, text: "Large Label"),
                    StyleLabel(style: .label, text: "Standard Label"),
                    StyleLabel(style: .labelSmall, text: "Small Label"),
                    StyleLabel(style: .caption, text: "Regular caption text"),
                    StyleLabel(style: .captionMedium, text: "Medium weight caption"),
                ]
            }
        }
    }

    public static func colorVariations() -> UIViewController {
        let primaryLabel = StyleLabel(style: .body, text: "Primary Text")
        primaryLabel.setTextColorStyle(SemanticColor.Colors.textPrimary)

        let secondaryLabel = StyleLabel(style: .body, text: "Secondary Text")
        secondaryLabel.setTextColorStyle(SemanticColor.Colors.textSecondary)

        let tertiaryLabel = StyleLabel(style: .body, text: "Tertiary Text")
        tertiaryLabel.setTextColorStyle(SemanticColor.Colors.textTertiary)

        let errorLabel = StyleLabel(style: .body, text: "Error Text")
        errorLabel.setTextColorStyle(SemanticColor.Colors.textError)

        let successLabel = StyleLabel(style: .body, text: "Success Text")
        successLabel.setTextColorStyle(SemanticColor.Colors.textSuccess)

        let warningLabel = StyleLabel(style: .body, text: "Warning Text")
        warningLabel.setTextColorStyle(SemanticColor.Colors.textWarning)

        return PreviewContainer.create {
            UIStackView.vertical(alignment: .leading) {
                [primaryLabel, secondaryLabel, tertiaryLabel, errorLabel, successLabel, warningLabel]
            }
        }
    }

    public static func longText() -> UIViewController {
        return PreviewContainer.createScrollable {
            UIStackView.vertical(alignment: .leading) {
                [
                    StyleLabel(style: .title, text: "Article Title"),
                    StyleLabel(style: .body, text: "This is a longer example of body text that demonstrates how the typography system handles multiple lines of content. It should wrap naturally and maintain proper line spacing and readability."),
                    StyleLabel(style: .caption, text: "This is a longer caption that shows how smaller text handles wrapping and maintains readability even with extended content."),
                ]
            }
        }
    }
}
#endif

// MARK: - Previews

#if canImport(SwiftUI) && DEBUG
    import SwiftUI

    @available(iOS 17.0, *)
    #Preview("Typography Scale") {
        StyleLabelPreviews.typographyScale()
    }

    @available(iOS 17.0, *)
    #Preview("Color Variations") {
        StyleLabelPreviews.colorVariations()
    }

    @available(iOS 17.0, *)
    #Preview("Long Text") {
        StyleLabelPreviews.longText()
    }
#endif
