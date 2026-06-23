import SwiftUI

/// A reusable tappable field that shows a label, an icon/content area, a title, and a trailing chevron.
/// Used for country pickers, dropdown selectors, etc.
public struct SelectionField<LeadingContent: View>: View {

    private let label: LocalizedStringKey
    private let title: String?
    private let placeholder: LocalizedStringKey
    private let leadingContent: LeadingContent?
    private let action: () -> Void

    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let backgroundColor: Color

    public init(
        label: LocalizedStringKey,
        title: String?,
        placeholder: LocalizedStringKey = "Select",
        @ViewBuilder leadingContent: () -> LeadingContent,
        cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusLarge,
        padding: CGFloat = Spacing.Semantic.componentPadding,
        backgroundColor: Color = SemanticColor.Colors.textFieldBG.swiftUIColor,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.title = title
        self.placeholder = placeholder
        self.leadingContent = leadingContent()
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(action: action) {
                HStack(spacing: Spacing.Semantic.componentMargin) {
                    if let leadingContent {
                        leadingContent
                    }

                    if let title, !title.isEmpty {
                        Text(title)
                            .font(.regular(.body))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    } else {
                        Text(placeholder)
                            .font(.regular(.body))
                            .foregroundStyle(SemanticColor.Colors.textTertiary.swiftUIColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                }
                .padding(padding)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .buttonStyle(.plain)
        }
    }
}

extension SelectionField where LeadingContent == EmptyView {
    /// Convenience init without leading content.
    public init(
        label: LocalizedStringKey,
        title: String?,
        placeholder: LocalizedStringKey = "Select",
        cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusLarge,
        padding: CGFloat = Spacing.Semantic.componentPadding,
        backgroundColor: Color = SemanticColor.Colors.textFieldBG.swiftUIColor,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.title = title
        self.placeholder = placeholder
        self.leadingContent = nil
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.action = action
    }
}

#Preview("With content") {
    VStack(spacing: 16) {
        SelectionField(
            label: "Country of Residence",
            title: "United Arab Emirates",
            leadingContent: {
                Circle()
                    .fill(.blue)
                    .frame(width: 24, height: 24)
            },
            action: {}
        )

        SelectionField(
            label: "Nationality",
            title: nil,
            placeholder: "Select your nationality",
            leadingContent: {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
            },
            action: {}
        )

        SelectionField(
            label: "Gender",
            title: "Male",
            action: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
