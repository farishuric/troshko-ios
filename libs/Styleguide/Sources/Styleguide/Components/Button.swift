import UIKit

public class StyleButton: UIButton {
    // MARK: - Button Styles

    public enum Style {
        case primary
        case secondary
        case tertiary
        case destructive
        case ghost
    }

    public enum Size {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: Spacing.Semantic.buttonHeightSmall
            case .medium: Spacing.Semantic.buttonHeight
            case .large: Spacing.Semantic.buttonHeightLarge
            }
        }

        var typographyConfig: TypographyConfig {
            switch self {
            case .small: return Typography.buttonSmall
            case .medium: return Typography.button
            case .large: return Typography.buttonLarge
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.Semantic.componentPadding
            case .medium: return Spacing.Semantic.sectionSpacing
            case .large: return Spacing.Semantic.screenPadding
            }
        }
    }

    // MARK: - Properties

    public var buttonStyle: Style = .primary {
        didSet { updateAppearance() }
    }

    public var buttonSize: Size = .medium {
        didSet { updateAppearance() }
    }

    public var isLoading: Bool = false {
        didSet { updateLoadingState() }
    }

    public var title: String? {
        didSet { setTitle(title, for: .normal) }
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    public convenience init(style: Style, size: Size = .medium) {
        self.init(frame: .zero)
        buttonStyle = style
        buttonSize = size
        setupButton()
    }

    public convenience init(style: Style, size: Size = .medium, title: String) {
        self.init(style: style, size: size)
        setTitle(title, for: .normal)
    }

    // MARK: - Setup

    private func setupButton() {
        setupLoadingIndicator()
        updateAppearance()
        setupConstraints()
    }

    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: buttonSize.height),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // Typography
        let config = buttonSize.typographyConfig
        titleLabel?.font = config.font

        // Colors and styling
        switch buttonStyle {
        case .primary:
            backgroundColor = SemanticColor.Colors.buttonPrimary.color
            setTitleColor(SemanticColor.Colors.textInverse.color, for: .normal)
            setTitleColor(SemanticColor.Colors.textInverse.color.withAlphaComponent(0.6), for: .disabled)
            layer.cornerRadius = Spacing.Semantic.cornerRadiusMedium

        case .secondary:
            backgroundColor = SemanticColor.Colors.buttonSecondary.color
            setTitleColor(SemanticColor.Colors.textPrimary.color, for: .normal)
            setTitleColor(SemanticColor.Colors.textSecondary.color, for: .disabled)
            layer.cornerRadius = Spacing.Semantic.cornerRadiusMedium
            layer.borderWidth = Spacing.Semantic.borderWidth
            layer.borderColor = SemanticColor.Colors.borderPrimary.color.cgColor

        case .tertiary:
            backgroundColor = UIColor.clear
            setTitleColor(SemanticColor.Colors.buttonPrimary.color, for: .normal)
            setTitleColor(SemanticColor.Colors.textSecondary.color, for: .disabled)

        case .destructive:
            backgroundColor = SemanticColor.Colors.buttonDestructive.color
            setTitleColor(SemanticColor.Colors.textInverse.color, for: .normal)
            setTitleColor(SemanticColor.Colors.textInverse.color.withAlphaComponent(0.6), for: .disabled)
            layer.cornerRadius = Spacing.Semantic.cornerRadiusMedium

        case .ghost:
            backgroundColor = UIColor.clear
            setTitleColor(SemanticColor.Colors.textPrimary.color, for: .normal)
            setTitleColor(SemanticColor.Colors.textSecondary.color, for: .disabled)
            layer.cornerRadius = Spacing.Semantic.cornerRadiusMedium
        }

        // Content insets
        contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: buttonSize.horizontalPadding,
            bottom: 0,
            right: buttonSize.horizontalPadding
        )

        // Shadow
        if buttonStyle == .primary || buttonStyle == .destructive {
            layer.shadowColor = SemanticColor.Colors.textPrimary.color.cgColor
            layer.shadowOffset = Spacing.Semantic.shadowOffset
            layer.shadowRadius = Spacing.Semantic.shadowRadius
            layer.shadowOpacity = Spacing.Semantic.shadowOpacity
        } else {
            layer.shadowOpacity = 0
        }
    }

    private func updateLoadingState() {
        if isLoading {
            loadingIndicator.startAnimating()
            titleLabel?.alpha = 0
            isEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            titleLabel?.alpha = 1
            isEnabled = true
        }
    }

    // MARK: - Public Methods

    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        // Update constraints when title changes
        setNeedsLayout()
    }

    override public var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        // Ensure minimum touch target
        if bounds.height < Spacing.Semantic.minimumTouchTarget {
            frame.size.height = Spacing.Semantic.minimumTouchTarget
        }
    }
}

// MARK: - Preview Builders (Public for Testing)

#if DEBUG
@available(iOS 17.0, *)
public enum StyleButtonPreviews {
    public static func buttonStyles() -> UIViewController {
        let smallPrimary = StyleButton(style: .primary, size: .small, title: "Small Primary")
        let mediumPrimary = StyleButton(style: .primary, size: .medium, title: "Medium Primary")
        let largePrimary = StyleButton(style: .primary, size: .large, title: "Large Primary")

        let loadingButton = StyleButton(style: .primary, size: .medium, title: "Loading...")
        // loadingButton.isLoading = true

        let secondaryButton = StyleButton(style: .secondary, size: .medium, title: "Secondary Button")
        let tertiaryButton = StyleButton(style: .tertiary, size: .medium, title: "Tertiary Button")
        let destructiveButton = StyleButton(style: .destructive, size: .medium, title: "Destructive Button")
        let ghostButton = StyleButton(style: .ghost, size: .medium, title: "Ghost Button")

        return PreviewContainer.createScrollable {
            UIStackView.vertical {
                [smallPrimary, mediumPrimary, largePrimary, loadingButton, secondaryButton, tertiaryButton, destructiveButton, ghostButton]
            }
        }
    }

    public static func buttonSizes() -> UIViewController {
        let smallButton = StyleButton(style: .primary, size: .small, title: "Small Button")
        let mediumButton = StyleButton(style: .primary, size: .medium, title: "Medium Button")
        let largeButton = StyleButton(style: .primary, size: .large, title: "Large Button")

        return PreviewContainer.create {
            UIStackView.vertical {
                [smallButton, mediumButton, largeButton]
            }
        }
    }

    public static func buttonDarkMode() -> UIViewController {
        let primaryButton = StyleButton(style: .primary, size: .medium, title: "Primary Button")
        let secondaryButton = StyleButton(style: .secondary, size: .medium, title: "Secondary Button")
        let tertiaryButton = StyleButton(style: .tertiary, size: .medium, title: "Tertiary Button")

        return PreviewContainer.create {
            UIStackView.vertical {
                [primaryButton, secondaryButton, tertiaryButton]
            }
        }
    }
}
#endif

// MARK: - Previews

#if canImport(SwiftUI) && DEBUG
    import SwiftUI

    @available(iOS 17.0, *)
    #Preview("Button Styles") {
        StyleButtonPreviews.buttonStyles()
    }

    @available(iOS 17.0, *)
    #Preview("Button Sizes") {
        StyleButtonPreviews.buttonSizes()
    }

    @available(iOS 17.0, *)
    #Preview("Dark Mode") {
        StyleButtonPreviews.buttonDarkMode()
    }
#endif
