import SwiftUI

// MARK: - Floating / glass surfaces

public extension View {
    /// Elevated, borderless floating surface: a translucent near-white card over a
    /// thin material, lifted with a soft shadow. The core building block of the
    /// soft-floating wellness UI — use this instead of bordered/outlined cards.
    func floatingCard(cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusXXXLarge) -> some View {
        modifier(FloatingCardModifier(cornerRadius: cornerRadius))
    }

    /// Frosted glass surface: thin material with an ultra-light highlight stroke.
    /// Lighter than `floatingCard` — for nested chrome / overlays.
    func glassSurface(cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusXXLarge) -> some View {
        modifier(GlassSurfaceModifier(cornerRadius: cornerRadius))
    }
}

public struct FloatingCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusXXXLarge) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return content
            .background {
                shape
                    .fill(SemanticColor.Colors.surfaceCard.swiftUIColor.opacity(0.78))
                    .background(.ultraThinMaterial, in: shape)
            }
            .overlay {
                shape.strokeBorder(
                    SemanticColor.Colors.plainWhite.swiftUIColor.opacity(0.12),
                    lineWidth: Spacing.Semantic.borderWidth
                )
            }
            .clipShape(shape)
            .softShadow()
    }
}

public struct GlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusXXLarge) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return content
            .background(.ultraThinMaterial, in: shape)
            .overlay {
                shape.strokeBorder(
                    SemanticColor.Colors.plainWhite.swiftUIColor.opacity(0.6),
                    lineWidth: Spacing.Semantic.borderWidth
                )
            }
            .clipShape(shape)
    }
}
