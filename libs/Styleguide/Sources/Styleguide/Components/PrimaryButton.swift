import SwiftUI

public struct PrimaryButton<Label: View>: View {
    let label: Label
    let isLoading: Bool
    let action: () -> Void

    public init(
        isLoading: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(SemanticColor.Colors.textInverse.swiftUIColor)
                } else {
                    label
                        .font(.semibold(.body))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.Semantic.buttonHeight)
        }
        .buttonStyle(PrimaryButtonStyle())
        .clipShape(RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium))
    }
}

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        let primary = SemanticColor.Colors.buttonPrimary.swiftUIColor
        configuration.label
            .foregroundStyle(isEnabled ? SemanticColor.Colors.textInverse.swiftUIColor : primary)
            .background(isEnabled ? primary : primary.opacity(0.2))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
#Preview("Enabled") {
    VStack(spacing: 16) {
        PrimaryButton(action: {}) { Text("Continue") }
        PrimaryButton(isLoading: true, action: {}) { Text("Loading...") }
        PrimaryButton(action: {}) { Text("Disabled") }
            .disabled(true)
    }
    .padding()
}
#endif
