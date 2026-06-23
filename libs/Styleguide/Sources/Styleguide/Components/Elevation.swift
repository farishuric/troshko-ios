import SwiftUI

// MARK: - Soft elevation modifiers

public extension View {
    /// Gentle lift for floating surfaces — large, low-opacity shadow (no border).
    /// The default elevation for the soft-floating wellness UI.
    func softShadow() -> some View {
        shadow(
            color: SemanticColor.Colors.textPrimary.swiftUIColor
                .opacity(Double(Spacing.Semantic.shadowSoftOpacity)),
            radius: Spacing.Semantic.shadowSoftRadius,
            x: Spacing.Semantic.shadowSoftOffset.width,
            y: Spacing.Semantic.shadowSoftOffset.height
        )
    }

    /// Stronger lift for the most prominent element on a screen (e.g. the primary CTA).
    func floatingShadow() -> some View {
        shadow(
            color: SemanticColor.Colors.textPrimary.swiftUIColor
                .opacity(Double(Spacing.Semantic.shadowFloatingOpacity)),
            radius: Spacing.Semantic.shadowFloatingRadius,
            x: Spacing.Semantic.shadowFloatingOffset.width,
            y: Spacing.Semantic.shadowFloatingOffset.height
        )
    }
}
