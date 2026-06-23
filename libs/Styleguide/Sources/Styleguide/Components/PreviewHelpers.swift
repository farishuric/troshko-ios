import UIKit

#if canImport(SwiftUI) && DEBUG
    import SwiftUI

    // MARK: - Preview Container Helper

    @available(iOS 17.0, *)
    public struct PreviewContainer {
        public static func create(
            _ content: () -> UIView
        ) -> UIViewController {
            let container = UIViewController()
            let view = content()

            container.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor, constant: 20),
                view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor, constant: -20),
                view.bottomAnchor.constraint(lessThanOrEqualTo: container.view.bottomAnchor, constant: -20),
            ])

            container.view.backgroundColor = .systemBackground
            return container
        }

        public static func createScrollable(
            _ content: () -> UIView
        ) -> UIViewController {
            let container = UIViewController()
            let scrollView = UIScrollView()
            let contentView = content()

            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false

            container.view.addSubview(scrollView)
            scrollView.addSubview(contentView)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),

                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            ])

            container.view.backgroundColor = .systemBackground
            return container
        }
    }

    // MARK: - Stack View Helpers

    @available(iOS 17.0, *)
    public extension UIStackView {
        static func vertical(
            spacing: CGFloat = 16,
            alignment: UIStackView.Alignment = .fill,
            distribution: UIStackView.Distribution = .fill,
            _ content: () -> [UIView]
        ) -> UIStackView {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = spacing
            stackView.alignment = alignment
            stackView.distribution = distribution
            stackView.translatesAutoresizingMaskIntoConstraints = false

            content().forEach { stackView.addArrangedSubview($0) }
            return stackView
        }

        static func horizontal(
            spacing: CGFloat = 12,
            alignment: UIStackView.Alignment = .fill,
            distribution: UIStackView.Distribution = .fill,
            _ content: () -> [UIView]
        ) -> UIStackView {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = spacing
            stackView.alignment = alignment
            stackView.distribution = distribution
            stackView.translatesAutoresizingMaskIntoConstraints = false

            content().forEach { stackView.addArrangedSubview($0) }
            return stackView
        }
    }

    // MARK: - Preview Section Helper

    @available(iOS 17.0, *)
    public struct PreviewSection {
        public static func create(
            title: String,
            _ content: () -> UIView
        ) -> UIView {
            let container = UIView()
            let stackView = UIStackView.vertical {
                [
                    StyleLabel(style: .headline, text: title),
                    content(),
                ]
            }

            container.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: container.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])

            return container
        }
    }

    // MARK: - Component Grid Helper

    @available(iOS 17.0, *)
    public struct ComponentGrid {
        public static func create(
            columns: Int = 2,
            spacing: CGFloat = 12,
            _ content: () -> [UIView]
        ) -> UIView {
            let container = UIView()
            let views = content()

            // Create a vertical stack for rows
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.spacing = spacing
            verticalStack.alignment = .fill
            verticalStack.distribution = .fill
            verticalStack.translatesAutoresizingMaskIntoConstraints = false

            // Group views into rows
            for i in stride(from: 0, to: views.count, by: columns) {
                let rowViews = Array(views[i ..< min(i + columns, views.count)])
                let horizontalStack = UIStackView.horizontal(
                    spacing: spacing,
                    distribution: .fillEqually
                ) { rowViews }

                verticalStack.addArrangedSubview(horizontalStack)
            }

            container.addSubview(verticalStack)
            verticalStack.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                verticalStack.topAnchor.constraint(equalTo: container.topAnchor),
                verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])

            return container
        }
    }

    // MARK: - Button Group Helper

    @available(iOS 17.0, *)
    public struct ButtonGroup {
        public static func create(
            _ content: () -> [StyleButton]
        ) -> UIView {
            let buttons = content()
            return UIStackView.horizontal(
                spacing: 12,
                distribution: .fillEqually
            ) { buttons }
        }
    }

    // MARK: - Form Helper

    @available(iOS 17.0, *)
    public struct FormPreview {
        public static func create(
            title: String? = nil,
            _ content: () -> [UIView]
        ) -> UIView {
            var views = content()

            if let title = title {
                let titleLabel = StyleLabel(style: .headline, text: title)
                views.insert(titleLabel, at: 0)
            }

            return UIStackView.vertical(spacing: 16) { views }
        }
    }

    // MARK: - Color Swatch Helper

    @available(iOS 17.0, *)
    public struct ColorSwatch {
        public static func create(
            color: UIColor,
            name: String
        ) -> UIView {
            let container = UIView()

            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 8
            colorView.translatesAutoresizingMaskIntoConstraints = false

            let label = StyleLabel(style: .caption, text: name)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(colorView)
            container.addSubview(label)

            NSLayoutConstraint.activate([
                colorView.topAnchor.constraint(equalTo: container.topAnchor),
                colorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                colorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                colorView.heightAnchor.constraint(equalToConstant: 60),

                label.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])

            return container
        }
    }

    // MARK: - Configure Extension

    @available(iOS 17.0, *)
    public extension UIView {
        func configure(_ block: (Self) -> Void) -> Self {
            block(self)
            return self
        }
    }

    // MARK: - Preview Traits Helper

    // Note: Use SwiftUI's built-in preview traits like .darkMode, .compact, .regular
    // Example: #Preview("Dark Mode", traits: .darkMode) { ... }

#endif
