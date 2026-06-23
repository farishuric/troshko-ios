import SwiftUI

public struct PasswordStrengthView: View {

    private let password: String

    public init(password: String) {
        self.password = password
    }

    private var hasMinLength: Bool { password.count >= 8 }
    private var hasNumber: Bool { password.contains(where: \.isNumber) }
    private var hasUppercase: Bool { password.contains(where: \.isUppercase) }
    private var hasSpecialChar: Bool {
        password.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
            row(met: hasMinLength, labelKey: "PASSWORD_REQUIREMENT_MIN_LENGTH")
            row(met: hasNumber, labelKey: "PASSWORD_REQUIREMENT_NUMBER")
            row(met: hasUppercase, labelKey: "PASSWORD_REQUIREMENT_UPPERCASE")
            row(met: hasSpecialChar, labelKey: "PASSWORD_REQUIREMENT_SPECIAL")
        }
    }

    @ViewBuilder
    private func row(met: Bool, labelKey: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(
                    met
                        ? SemanticColor.Colors.textSuccess.swiftUIColor
                        : SemanticColor.Colors.textSecondary.swiftUIColor
                )
                .font(.system(size: 13, weight: .medium))
                .contentTransition(.symbolEffect(.replace))
                .animation(.easeInOut(duration: 0.2), value: met)

            Text(LocalizedStringKey(labelKey))
                .font(.regular(.small))
                .foregroundStyle(
                    met
                        ? SemanticColor.Colors.textPrimary.swiftUIColor
                        : SemanticColor.Colors.textSecondary.swiftUIColor
                )
                .animation(.easeInOut(duration: 0.2), value: met)
        }
    }
}
