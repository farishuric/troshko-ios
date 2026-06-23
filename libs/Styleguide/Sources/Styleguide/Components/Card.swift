import UIKit

public class StyleCard: UIView {
    // MARK: - Card Styles

    public enum Style {
        case elevated
        case outlined
        case filled
        case flat
    }

    public enum Size {
        case small
        case medium
        case large
        case flexible

        var cornerRadius: CGFloat {
            switch self {
            case .small: return Spacing.Semantic.cornerRadiusSmall
            case .medium: return Spacing.Semantic.cornerRadiusMedium
            case .large: return Spacing.Semantic.cornerRadiusLarge
            case .flexible: return Spacing.Semantic.cornerRadiusMedium
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return Spacing.Semantic.componentMargin
            case .medium: return Spacing.Semantic.componentPadding
            case .large: return Spacing.Semantic.sectionSpacing
            case .flexible: return Spacing.Semantic.componentPadding
            }
        }
    }

    // MARK: - Properties

    public var cardStyle: Style = .elevated {
        didSet { updateAppearance() }
    }

    public var cardSize: Size = .medium {
        didSet { updateAppearance() }
    }

    public var contentView = UIView()

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
    }

    public convenience init(style: Style, size: Size = .medium) {
        self.init(frame: .zero)
        cardStyle = style
        cardSize = size
        setupCard()
    }

    // MARK: - Setup

    private func setupCard() {
        setupContentView()
        updateAppearance()
    }

    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: cardSize.padding),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: cardSize.padding),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -cardSize.padding),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -cardSize.padding),
        ])
    }

    // MARK: - Appearance

    private func updateAppearance() {
        layer.cornerRadius = cardSize.cornerRadius

        switch cardStyle {
        case .elevated:
            backgroundColor = SemanticColor.Colors.backgroundPrimary.color
            layer.shadowColor = SemanticColor.Colors.textPrimary.color.cgColor
            layer.shadowOffset = Spacing.Semantic.shadowOffset
            layer.shadowRadius = Spacing.Semantic.shadowRadius
            layer.shadowOpacity = Spacing.Semantic.shadowOpacity
            layer.borderWidth = 0

        case .outlined:
            backgroundColor = SemanticColor.Colors.backgroundPrimary.color
            layer.borderWidth = Spacing.Semantic.borderWidth
            layer.borderColor = SemanticColor.Colors.borderPrimary.color.cgColor
            layer.shadowOpacity = 0

        case .filled:
            backgroundColor = SemanticColor.Colors.backgroundSecondary.color
            layer.borderWidth = 0
            layer.shadowOpacity = 0

        case .flat:
            backgroundColor = UIColor.clear
            layer.borderWidth = 0
            layer.shadowOpacity = 0
        }

        // Update content view constraints
        contentView.removeFromSuperview()
        setupContentView()
    }

    // MARK: - Public Methods

    public func addContent(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    public func removeAllContent() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    public func setContentPadding(_ padding: CGFloat) {
        contentView.removeFromSuperview()
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
}

// MARK: - Previews

#if canImport(SwiftUI) && DEBUG
    import SwiftUI

    @available(iOS 17.0, *)
    #Preview("Card Styles") {
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

        // Elevated card
        let elevatedCard = StyleCard(style: .elevated, size: .medium)
        let elevatedTitle = StyleLabel(style: .title, text: "Elevated Card")
        let elevatedBody = StyleLabel(style: .body, text: "This is an elevated card with shadow")
        elevatedCard.addContent(elevatedTitle)
        elevatedCard.addContent(elevatedBody)

        // Outlined card
        let outlinedCard = StyleCard(style: .outlined, size: .medium)
        let outlinedTitle = StyleLabel(style: .title, text: "Outlined Card")
        let outlinedBody = StyleLabel(style: .body, text: "This is an outlined card with border")
        outlinedCard.addContent(outlinedTitle)
        outlinedCard.addContent(outlinedBody)

        // Filled card
        let filledCard = StyleCard(style: .filled, size: .medium)
        let filledTitle = StyleLabel(style: .title, text: "Filled Card")
        let filledBody = StyleLabel(style: .body, text: "This is a filled card with background")
        filledCard.addContent(filledTitle)
        filledCard.addContent(filledBody)

        // Flat card
        let flatCard = StyleCard(style: .flat, size: .medium)
        let flatTitle = StyleLabel(style: .title, text: "Flat Card")
        let flatBody = StyleLabel(style: .body, text: "This is a flat card with no styling")
        flatCard.addContent(flatTitle)
        flatCard.addContent(flatBody)

        stackView.addArrangedSubview(elevatedCard)
        stackView.addArrangedSubview(outlinedCard)
        stackView.addArrangedSubview(filledCard)
        stackView.addArrangedSubview(flatCard)

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
    #Preview("Card Sizes") {
        let container = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Small card
        let smallCard = StyleCard(style: .elevated, size: .small)
        let smallTitle = StyleLabel(style: .subtitle, text: "Small Card")
        let smallBody = StyleLabel(style: .bodySmall, text: "Small card content")
        smallCard.addContent(smallTitle)
        smallCard.addContent(smallBody)

        // Medium card
        let mediumCard = StyleCard(style: .elevated, size: .medium)
        let mediumTitle = StyleLabel(style: .title, text: "Medium Card")
        let mediumBody = StyleLabel(style: .body, text: "Medium card content")
        mediumCard.addContent(mediumTitle)
        mediumCard.addContent(mediumBody)

        // Large card
        let largeCard = StyleCard(style: .elevated, size: .large)
        let largeTitle = StyleLabel(style: .titleLarge, text: "Large Card")
        let largeBody = StyleLabel(style: .bodyLarge, text: "Large card content with more padding")
        largeCard.addContent(largeTitle)
        largeCard.addContent(largeBody)

        stackView.addArrangedSubview(smallCard)
        stackView.addArrangedSubview(mediumCard)
        stackView.addArrangedSubview(largeCard)

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
    #Preview("Card with Multiple Content") {
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

        // Article card with multiple elements
        let articleCard = StyleCard(style: .elevated, size: .large)
        let articleTitle = StyleLabel(style: .title, text: "Article Title")
        let articleBody = StyleLabel(style: .body, text: "This is a comprehensive article card that demonstrates how multiple content elements can be organized within a single card layout.")
        let articleCaption = StyleLabel(style: .caption, text: "Published 2 hours ago")
        let articleAuthor = StyleLabel(style: .label, text: "By John Doe")

        articleCard.addContent(articleTitle)
        articleCard.addContent(articleBody)
        articleCard.addContent(articleCaption)
        articleCard.addContent(articleAuthor)

        // Product card
        let productCard = StyleCard(style: .outlined, size: .medium)
        let productTitle = StyleLabel(style: .subtitle, text: "Product Name")
        let productPrice = StyleLabel(style: .title, text: "$29.99")
        let productDescription = StyleLabel(style: .bodySmall, text: "Product description goes here")

        productCard.addContent(productTitle)
        productCard.addContent(productPrice)
        productCard.addContent(productDescription)

        stackView.addArrangedSubview(articleCard)
        stackView.addArrangedSubview(productCard)

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
