import SwiftUI

public enum SensoryCardType: Equatable {
    case hypersensitivity
    case neutral
    case hyposensitivity

    /// Traffic-light accent for the answer: Hyper = red, Neutral = amber, Hypo = green.
    var accentColor: Color {
        switch self {
        case .hypersensitivity: return SemanticColor.Colors.error.swiftUIColor
        case .neutral:          return SemanticColor.Colors.warning.swiftUIColor
        case .hyposensitivity:  return SemanticColor.Colors.success.swiftUIColor
        }
    }

    /// Tinted face glyph conveying the reaction intensity.
    var faceAssetName: String {
        switch self {
        case .hypersensitivity: return "FaceOverwhelmed"
        case .neutral:          return "FaceNeutral"
        case .hyposensitivity:  return "FaceCalm"
        }
    }
}

public struct SensoryOptionCardView: View {
    let text: String
    let subtitle: String?
    let sensoryCardType: SensoryCardType
    let isSelected: Bool
    let onTap: () -> Void

    public init(
        text: String,
        subtitle: String? = nil,
        sensoryCardType: SensoryCardType,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.text = text
        self.subtitle = subtitle
        self.sensoryCardType = sensoryCardType
        self.isSelected = isSelected
        self.onTap = onTap
    }

    private var accent: Color { sensoryCardType.accentColor }

    public var body: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            onTap()
        }) {
            HStack(spacing: Spacing.Semantic.componentMargin) {
                faceBadge
                textContent
                Spacer()
                checkbox
            }
            .padding(Spacing.Semantic.componentPadding)
            .background(
                isSelected
                    ? accent.opacity(0.12)
                    : SemanticColor.Colors.textFieldBG.swiftUIColor
            )
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium)
                    .strokeBorder(
                        isSelected ? accent : accent.opacity(0.35),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var faceBadge: some View {
        ZStack {
            Circle()
                .fill(isSelected ? accent : accent.opacity(0.15))
                .frame(width: 36, height: 36)

            Image(sensoryCardType.faceAssetName, bundle: .module)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(
                    isSelected ? SemanticColor.Colors.plainWhite.swiftUIColor : accent
                )
        }
        .scaleEffect(isSelected ? 1.12 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(text)
                .font(.medium(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                .multilineTextAlignment(.leading)

            if let subtitle {
                Text(subtitle)
                    .font(.regular(.small))
                    .foregroundStyle(accent)
            }
        }
    }

    private var checkbox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? accent : Color.clear)
                .frame(width: 18, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(
                            isSelected ? accent : accent.opacity(0.4),
                            lineWidth: 1.5
                        )
                )

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SemanticColor.Colors.plainWhite.swiftUIColor)
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        SensoryOptionCardView(
            text: "Finds it unpleasant or overwhelming",
            subtitle: "Hypersensitivity",
            sensoryCardType: .hypersensitivity,
            isSelected: true,
            onTap: {}
        )
        SensoryOptionCardView(
            text: "Reacts normally",
            subtitle: nil,
            sensoryCardType: .neutral,
            isSelected: false,
            onTap: {}
        )
        SensoryOptionCardView(
            text: "Seeks more stimulation",
            subtitle: "Hyposensitivity",
            sensoryCardType: .hyposensitivity,
            isSelected: false,
            onTap: {}
        )
    }
    .padding()
}
#endif
