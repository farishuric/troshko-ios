import SwiftUI

public struct QuestionnaireNavigationBar: View {
    let canGoPrevious: Bool
    let canGoNext: Bool
    let isLastCategory: Bool
    let isSubmitting: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    public init(
        canGoPrevious: Bool,
        canGoNext: Bool,
        isLastCategory: Bool,
        isSubmitting: Bool,
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.canGoPrevious = canGoPrevious
        self.canGoNext = canGoNext
        self.isLastCategory = isLastCategory
        self.isSubmitting = isSubmitting
        self.onPrevious = onPrevious
        self.onNext = onNext
    }

    public var body: some View {
        HStack(spacing: Spacing.Semantic.componentMargin) {
            if canGoPrevious {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onPrevious()
                }) {
                    Text("Previous")
                        .font(.semibold(.body))
                        .frame(height: Spacing.Semantic.buttonHeight)
                        .padding(.horizontal, Spacing.Semantic.componentPadding)
                }
                .buttonStyle(OutlineButtonStyle())
                .disabled(isSubmitting)
            }

            PrimaryButton(isLoading: isSubmitting, action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onNext()
            }) {
                if !isSubmitting {
                    Text(isLastCategory ? "Submit" : "Next question")
                }
            }
            .disabled(!canGoNext || isSubmitting)
        }
        .padding(.horizontal, Spacing.Semantic.screenMargin)
        .padding(.vertical, Spacing.Semantic.componentMargin)
    }
}

private struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium)
                    .strokeBorder(SemanticColor.Colors.borderPrimary.swiftUIColor, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        QuestionnaireNavigationBar(
            canGoPrevious: true,
            canGoNext: true,
            isLastCategory: false,
            isSubmitting: false,
            onPrevious: {},
            onNext: {}
        )
        QuestionnaireNavigationBar(
            canGoPrevious: false,
            canGoNext: false,
            isLastCategory: false,
            isSubmitting: false,
            onPrevious: {},
            onNext: {}
        )
        QuestionnaireNavigationBar(
            canGoPrevious: true,
            canGoNext: true,
            isLastCategory: true,
            isSubmitting: true,
            onPrevious: {},
            onNext: {}
        )
    }
    .padding()
}
#endif
