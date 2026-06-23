import SwiftUI

/// The elevated, floating container at the heart of the calm & fluid language: a
/// translucent frosted surface lifted with a soft shadow. Home cards, the AI
/// advisor surfaces, and `Banner` all sit in one of these.
///
/// Wraps the `floatingCard()` surface modifier with consistent padding so callers
/// just drop content in. Build from tokens only — corner radius and padding default
/// to Styleguide values.
public struct FloatingCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let content: Content

    public init(
        cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusXXXLarge,
        padding: CGFloat = Spacing.Semantic.componentPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .floatingCard(cornerRadius: cornerRadius)
    }
}

#if DEBUG
#Preview {
    ZStack {
        AmbientGradientBackground()
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            FloatingCard {
                VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                    Text("Saved this month")
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                    Text("420,00 KM")
                        .font(.semibold(.title))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                }
            }
            .softAppear(index: 0)

            FloatingCard {
                Text("A second floating card, drifting in just behind the first.")
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
            }
            .softAppear(index: 1)
        }
        .padding(Spacing.Semantic.screenMargin)
    }
}
#endif
