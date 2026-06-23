import UIKit

public class StyleTextField: UITextField {
    // MARK: - TextField Styles

    public enum Style {
        case standard
        case outlined
        case filled
        case search
    }

    public enum Size {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: return Spacing.Semantic.buttonHeightSmall
            case .medium: return Spacing.Semantic.buttonHeight
            case .large: return Spacing.Semantic.buttonHeightLarge
            }
        }

        var typographyConfig: TypographyConfig {
            switch self {
            case .small: return Typography.textFieldSmall
            case .medium: return Typography.textField
            case .large: return Typography.textFieldLarge
            }
        }

        var padding: UIEdgeInsets {
            switch self {
            case .small: return UIEdgeInsets(
                    top: Spacing.Semantic.componentMargin,
                    left: Spacing.Semantic.componentPadding,
                    bottom: Spacing.Semantic.componentMargin,
                    right: Spacing.Semantic.componentPadding
                )
            case .medium: return UIEdgeInsets(
                    top: Spacing.Semantic.componentPadding,
                    left: Spacing.Semantic.sectionSpacing,
                    bottom: Spacing.Semantic.componentPadding,
                    right: Spacing.Semantic.sectionSpacing
                )
            case .large: return UIEdgeInsets(
                    top: Spacing.Semantic.sectionSpacing,
                    left: Spacing.Semantic.screenPadding,
                    bottom: Spacing.Semantic.sectionSpacing,
                    right: Spacing.Semantic.screenPadding
                )
            }
        }
    }

    // MARK: - Properties

    public var fieldStyle: Style = .standard {
        didSet { updateAppearance() }
    }

    public var fieldSize: Size = .medium {
        didSet { updateAppearance() }
    }

    public var errorMessage: String? {
        didSet { updateErrorState() }
    }

    public var isValid: Bool = true {
        didSet { updateErrorState() }
    }

    private let errorLabel = UILabel()
    private var originalBorderColor: CGColor?

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    public convenience init(style: Style, size: Size = .medium) {
        self.init(frame: .zero)
        fieldStyle = style
        fieldSize = size
        setupTextField()
    }

    // MARK: - Setup

    private func setupTextField() {
        setupErrorLabel()
        updateAppearance()
        setupConstraints()
        setupTargets()
    }

    private func setupErrorLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = Typography.caption.font
        errorLabel.textColor = SemanticColor.Colors.error.color
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        superview?.addSubview(errorLabel)
    }

    private func setupConstraints() {
        guard let superview = superview else { return }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: fieldSize.height),
            errorLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: Spacing.Semantic.groupSpacing),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func setupTargets() {
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // Typography
        let config = fieldSize.typographyConfig
        font = config.font

        // Colors
        textColor = SemanticColor.Colors.textPrimary.color
        placeholder = placeholder

        // Background and border
        switch fieldStyle {
        case .standard:
            backgroundColor = SemanticColor.Colors.backgroundPrimary.color
            layer.borderWidth = 0
            layer.cornerRadius = 0
            borderStyle = .none

        case .outlined:
            backgroundColor = SemanticColor.Colors.backgroundPrimary.color
            layer.borderWidth = Spacing.Semantic.borderWidth
            layer.borderColor = SemanticColor.Colors.borderPrimary.color.cgColor
            layer.cornerRadius = Spacing.Semantic.cornerRadiusMedium
            borderStyle = .none

        case .filled:
            backgroundColor = SemanticColor.Colors.backgroundSecondary.color
            layer.borderWidth = 0
            layer.cornerRadius = Spacing.Semantic.cornerRadiusMedium
            borderStyle = .none

        case .search:
            backgroundColor = SemanticColor.Colors.backgroundSecondary.color
            layer.borderWidth = 0
            layer.cornerRadius = fieldSize.height / 2
            borderStyle = .none
        }

        // Store original border color
        originalBorderColor = layer.borderColor

        // Padding
        let padding = fieldSize.padding
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding.left, height: fieldSize.height))
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: padding.right, height: fieldSize.height))
        leftViewMode = .always
        rightViewMode = .always
    }

    private func updateErrorState() {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            errorLabel.text = errorMessage
            errorLabel.isHidden = false
            layer.borderColor = SemanticColor.Colors.error.color.cgColor
            textColor = SemanticColor.Colors.error.color
        } else if !isValid {
            layer.borderColor = SemanticColor.Colors.error.color.cgColor
            textColor = SemanticColor.Colors.error.color
            errorLabel.isHidden = true
        } else {
            layer.borderColor = originalBorderColor
            textColor = SemanticColor.Colors.textPrimary.color
            errorLabel.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func textFieldDidBeginEditing() {
        layer.borderColor = SemanticColor.Colors.accent.color.cgColor
        if fieldStyle == .outlined || fieldStyle == .filled {
            layer.borderWidth = 2
        }
    }

    @objc private func textFieldDidEndEditing() {
        if isValid && (errorMessage?.isEmpty ?? true) {
            layer.borderColor = originalBorderColor
        }
        if fieldStyle == .outlined || fieldStyle == .filled {
            layer.borderWidth = Spacing.Semantic.borderWidth
        }
    }

    @objc private func textFieldDidChange() {
        // Clear error state when user starts typing
        if !isValid || !(errorMessage?.isEmpty ?? true) {
            isValid = true
            errorMessage = nil
        }
    }

    // MARK: - Public Methods

    public func setError(_ message: String?) {
        errorMessage = message
        isValid = message == nil
    }

    public func clearError() {
        errorMessage = nil
        isValid = true
    }

    override public var placeholder: String? {
        didSet {
            if let placeholder = placeholder {
                attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [
                        .foregroundColor: SemanticColor.Colors.textTertiary.color,
                        .font: font ?? Typography.body.font,
                    ]
                )
            }
        }
    }
}

// MARK: - Previews

#if canImport(SwiftUI) && DEBUG
    import SwiftUI

    @available(iOS 17.0, *)
    #Preview("TextField Styles") {
        let container = UIViewController()
        let scrollView = UIScrollView()
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        container.view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        // Standard text field
        let standardField = StyleTextField(style: .standard, size: .medium)
        standardField.placeholder = "Standard Text Field"

        // Outlined text field
        let outlinedField = StyleTextField(style: .outlined, size: .medium)
        outlinedField.placeholder = "Outlined Text Field"
        outlinedField.text = "Sample text"

        // Filled text field
        let filledField = StyleTextField(style: .filled, size: .medium)
        filledField.placeholder = "Filled Text Field"

        // Search text field
        let searchField = StyleTextField(style: .search, size: .medium)
        searchField.placeholder = "Search..."

        stackView.addArrangedSubview(standardField)
        stackView.addArrangedSubview(outlinedField)
        stackView.addArrangedSubview(filledField)
        stackView.addArrangedSubview(searchField)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        container.view.backgroundColor = .systemBackground
        return container
    }

    @available(iOS 17.0, *)
    #Preview("TextField Sizes") {
        let container = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let smallField = StyleTextField(style: .outlined, size: .small)
        smallField.placeholder = "Small Text Field"

        let mediumField = StyleTextField(style: .outlined, size: .medium)
        mediumField.placeholder = "Medium Text Field"
        mediumField.text = "Sample text"

        let largeField = StyleTextField(style: .outlined, size: .large)
        largeField.placeholder = "Large Text Field"

        stackView.addArrangedSubview(smallField)
        stackView.addArrangedSubview(mediumField)
        stackView.addArrangedSubview(largeField)

        container.view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.view.trailingAnchor, constant: -20),
        ])

        container.view.backgroundColor = .systemBackground
        return container
    }

    @available(iOS 17.0, *)
    #Preview("Error States") {
        let container = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let errorField = StyleTextField(style: .outlined, size: .medium)
        errorField.placeholder = "Email Address"
        errorField.text = "invalid-email"
        errorField.setError("Please enter a valid email address")

        let validField = StyleTextField(style: .outlined, size: .medium)
        validField.placeholder = "Password"
        validField.text = "validpassword123"

        let invalidField = StyleTextField(style: .filled, size: .medium)
        invalidField.placeholder = "Confirm Password"
        invalidField.text = "different"
        invalidField.setError("Passwords do not match")

        stackView.addArrangedSubview(errorField)
        stackView.addArrangedSubview(validField)
        stackView.addArrangedSubview(invalidField)

        container.view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.view.trailingAnchor, constant: -20),
        ])

        container.view.backgroundColor = .systemBackground
        return container
    }

    @available(iOS 17.0, *)
    #Preview("Form Layout") {
        let container = UIViewController()
        let scrollView = UIScrollView()
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        container.view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        // Form title
        let titleLabel = StyleLabel(style: .title, text: "Contact Form")
        stackView.addArrangedSubview(titleLabel)

        // Form fields
        let firstNameField = StyleTextField(style: .outlined, size: .medium)
        firstNameField.placeholder = "First Name"

        let lastNameField = StyleTextField(style: .outlined, size: .medium)
        lastNameField.placeholder = "Last Name"

        let emailField = StyleTextField(style: .outlined, size: .medium)
        emailField.placeholder = "Email Address"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none

        let phoneField = StyleTextField(style: .outlined, size: .medium)
        phoneField.placeholder = "Phone Number"
        phoneField.keyboardType = .phonePad

        // Buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        let cancelButton = StyleButton(style: .secondary, size: .medium)
        cancelButton.setTitle("Cancel", for: .normal)

        let saveButton = StyleButton(style: .primary, size: .medium)
        saveButton.setTitle("Save", for: .normal)

        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)

        stackView.addArrangedSubview(firstNameField)
        stackView.addArrangedSubview(lastNameField)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(phoneField)
        stackView.addArrangedSubview(buttonStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        container.view.backgroundColor = .systemBackground
        return container
    }
#endif
