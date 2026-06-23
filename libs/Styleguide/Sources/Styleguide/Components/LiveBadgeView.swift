import SwiftUI

/// Capsule "● LIVE" badge — soft green fill, no border. Shown while live tracking.
public struct LiveBadgeView: View {
    private let title: LocalizedStringKey

    public init(title: LocalizedStringKey) {
        self.title = title
    }

    public var body: some View {
        HStack(spacing: Spacing.Semantic.groupSpacing) {
            Circle()
                .fill(SemanticColor.Colors.success.swiftUIColor)
                .frame(width: 7, height: 7)
            Text(title)
                .font(.semibold(.small))
                .foregroundStyle(SemanticColor.Colors.textSuccess.swiftUIColor)
                .textCase(.uppercase)
                .kerning(0.5)
        }
        .padding(.horizontal, Spacing.Semantic.componentMargin)
        .padding(.vertical, Spacing.Semantic.groupSpacing - 2)
        .background(Capsule().fill(SemanticColor.Colors.success.swiftUIColor.opacity(0.15)))
    }
}

#Preview {
    LiveBadgeView(title: "LIVE").padding(40)
}
