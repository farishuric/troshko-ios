import SwiftUI

/// An animated, floating info/tip banner — a `FloatingCard` tuned for a short
/// message with a leading icon. Drifts in calmly on appear (Reduce-Motion aware).
///
/// Phase 7 surfaces curated static tips through this. Copy is passed in already
/// localized by the caller; `Banner` adds no strings of its own.
public struct Banner: View {

    public enum Style {
        case info
        case success
        case tip

        var iconName: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .tip: return "lightbulb.fill"
            }
        }

        var accent: Color {
            switch self {
            case .info: return SemanticColor.Colors.info.swiftUIColor
            case .success: return SemanticColor.Colors.success.swiftUIColor
            case .tip: return SemanticColor.Colors.primary.swiftUIColor
            }
        }
    }

    private let style: Style
    private let title: String?
    private let message: String
    private let onDismiss: (() -> Void)?

    public init(
        style: Style = .info,
        title: String? = nil,
        message: String,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        FloatingCard {
            HStack(alignment: .top, spacing: Spacing.Semantic.itemSpacing) {
                Image(systemName: style.iconName)
                    .font(.regular(.large))
                    .foregroundStyle(style.accent)

                VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                    if let title {
                        Text(title)
                            .font(.semibold(.body))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    }
                    Text(message)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.regular(.small))
                            .foregroundStyle(SemanticColor.Colors.textTertiary.swiftUIColor)
                    }
                    .accessibilityLabel(Text(StyleguideStrings.Accessibility.close))
                }
            }
        }
        .softAppear()
    }
}

#if DEBUG
#Preview {
    ZStack {
        AmbientGradientBackground()
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Banner(
                style: .tip,
                title: "Tip",
                message: "You spent less on coffee this week — nice. Keep it up to hit your goal."
            )
            Banner(style: .info, message: "Your monthly overview is ready.") {}
            Banner(style: .success, title: "Goal reached", message: "You saved 200 KM this month.")
        }
        .padding(Spacing.Semantic.screenMargin)
    }
}
#endif
