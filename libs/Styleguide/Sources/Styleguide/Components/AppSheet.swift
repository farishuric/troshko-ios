import SwiftUI

// MARK: - Action

public struct AppSheetAction {
    public let title: String
    public let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

// MARK: - Content

public struct AppSheet: View {
    private let icon: String
    private let iconTint: Color?
    private let title: String
    private let message: String?
    private let footnote: String?
    private let primaryAction: AppSheetAction
    private let secondaryAction: AppSheetAction?

    public init(
        icon: String,
        iconTint: Color? = nil,
        title: String,
        message: String? = nil,
        footnote: String? = nil,
        primaryAction: AppSheetAction,
        secondaryAction: AppSheetAction? = nil
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.message = message
        self.footnote = footnote
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        VStack(spacing: Spacing.Semantic.sectionSpacing) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(iconTint ?? SemanticColor.Colors.primary.swiftUIColor)

            VStack(spacing: Spacing.Semantic.itemSpacing) {
                Text(title)
                    .font(.extraBold(.title))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

                if let message {
                    Text(attributedMessage(message))
                        .font(.regular(.body))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                }

                if let footnote {
                    Text(footnote)
                        .font(.regular(.small))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SemanticColor.Colors.textTertiary.swiftUIColor)
                }
            }

            VStack(spacing: Spacing.Semantic.groupSpacing) {
                PrimaryButton(action: primaryAction.action) {
                    Text(primaryAction.title)
                }

                if let secondary = secondaryAction {
                    Button(action: secondary.action) {
                        Text(secondary.title)
                            .font(.semibold(.body))
                            .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                    }
                    .frame(height: Spacing.Semantic.buttonHeight)
                }
            }
        }
        .padding(Spacing.Semantic.screenPadding)
        .frame(maxWidth: .infinity)
    }

    /// Renders the message as markdown so callers can emphasise parts (e.g. a
    /// bold hero name via `**…**`). `inlineOnlyPreservingWhitespace` keeps explicit
    /// line breaks (`\n`) intact for longer messages and only parses inline syntax.
    private func attributedMessage(_ message: String) -> AttributedString {
        (try? AttributedString(
            markdown: message,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(message)
    }
}

// MARK: - Modifier

extension View {
    /// Presents a custom bottom sheet over the current view.
    /// The sheet sizes itself to fit its content. When content exceeds 88% of
    /// the screen height it becomes scrollable. Drag down from the top of the
    /// scroll to dismiss (only when isDismissable is true).
    public func appSheet<Content: View>(
        isPresented: Binding<Bool>,
        isDismissable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            BottomSheetOverlay(
                isPresented: isPresented,
                isDismissable: isDismissable,
                sheetContent: content
            )
        }
    }
}

// Shared spring for presenting, dismissing and settling the sheet on finger release.
// A high damping fraction keeps the settle subtle (a gentle ease-out, barely overshoots).
private let sheetSpring = Animation.spring(response: 0.42, dampingFraction: 0.82)

// MARK: - Overlay

private struct BottomSheetOverlay<SheetContent: View>: View {
    @Binding var isPresented: Bool
    let isDismissable: Bool
    @ViewBuilder let sheetContent: () -> SheetContent

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    // Keep the dim strictly behind the sheet (zIndex 0 < 1) so it can
                    // never jump in front during the transition. On dismiss its fade is
                    // delayed until the sheet has slid away, so the order reads:
                    // sheet closes first, then the dim disappears.
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.animation(.easeInOut(duration: 0.2).delay(0.22))
                    ))
                    .zIndex(0)
                    .onTapGesture {
                        guard isDismissable else { return }
                        withAnimation(sheetSpring) { isPresented = false }
                    }

                BottomSheetPanel(
                    isPresented: $isPresented,
                    isDismissable: isDismissable,
                    content: sheetContent
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(sheetSpring, value: isPresented)
        .ignoresSafeArea()
    }
}

// Height taken by the drag handle (capsule + its vertical padding: 5 + 10*2).
private let sheetHandleAreaHeight: CGFloat = 25

// MARK: - Panel

private struct BottomSheetPanel<Content: View>: View {
    @Binding var isPresented: Bool
    let isDismissable: Bool
    @ViewBuilder let content: () -> Content

    @State private var dragOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        GeometryReader { screen in
            // Inset below the content: clears the home indicator, or falls back to
            // standard screen padding on devices without one.
            let bottomInset = max(screen.safeAreaInsets.bottom, Spacing.Semantic.screenPadding)
            // Never let the sheet grow past ~the screen (minus the drag handle); longer
            // content scrolls within this cap.
            let maxSheetHeight = screen.size.height * 0.9 - sheetHandleAreaHeight
            // Size the scroll area to the measured content, capped. `contentHeight`
            // already includes the bottom inset (the measured background wraps it).
            let scrollHeight = min(contentHeight, maxSheetHeight)
            let canScroll = contentHeight > maxSheetHeight

            VStack(spacing: 0) {
                dragHandle

                ScrollView(.vertical) {
                    content()
                        // Pin to the real screen width. Inside a vertical ScrollView,
                        // children that only declare `maxWidth: .infinity` collapse to
                        // their ~0 ideal width (the sliver bug), so give a definite width.
                        .frame(width: screen.size.width)
                        .padding(.bottom, bottomInset)
                        // Measure natural content height; a vertical ScrollView proposes
                        // unbounded height, so this is the true content height regardless
                        // of the frame we then pin below.
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: SheetContentHeightKey.self,
                                    value: geo.size.height
                                )
                            }
                        )
                }
                // Pin to the content height (capped) so the sheet hugs its content and
                // only scrolls once it would exceed the cap. Starts at 0 (handle only)
                // and grows once measured — so it can never flash to full screen.
                .frame(height: scrollHeight)
                .scrollDisabled(!canScroll)
            }
            .frame(maxWidth: .infinity)
            .onPreferenceChange(SheetContentHeightKey.self) { contentHeight = $0 }
            .background(SemanticColor.Colors.backgroundPrimary.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            // Sheet follows finger downward; never moves upward.
            .offset(y: max(0, dragOffset))
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        guard isDismissable, value.translation.height > 0 else { return }
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let fastFlick = value.predictedEndTranslation.height > 250
                        let farEnough = value.translation.height > 100
                        if isDismissable && (farEnough || fastFlick) {
                            withAnimation(sheetSpring) { isPresented = false }
                        } else {
                            // Released without dismissing: spring back to rest.
                            withAnimation(sheetSpring) { dragOffset = 0 }
                        }
                    }
            )
            .onAppear { dragOffset = 0 }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var dragHandle: some View {
        Capsule()
            .fill(SemanticColor.Colors.textTertiary.swiftUIColor)
            .frame(width: 40, height: 5)
            .padding(.vertical, 10)
            .accessibilityLabel(Text("Drag to dismiss"))
    }
}

// MARK: - Preference Keys

private struct SheetContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Info — non-dismissable") {
    Color.clear
        .appSheet(isPresented: .constant(true), isDismissable: false) {
            AppSheet(
                icon: "info.circle",
                title: "Beta Version Disclaimer",
                message: "You're exploring the Beta version of AISTHESIS app!\n\nThis version is for testing purposes only and may not fully represent the final product.\n\nYour patience and feedback are crucial as we refine the product. Thank you for being part of our journey!",
                footnote: "Version 1.0.0 (1)",
                primaryAction: AppSheetAction(title: "I understand") {},
                secondaryAction: AppSheetAction(title: "Close app") {}
            )
        }
}

#Preview("Warning — dismissable") {
    Color.clear
        .appSheet(isPresented: .constant(true)) {
            AppSheet(
                icon: "exclamationmark.triangle",
                iconTint: Color.orange,
                title: "Warning",
                message: "This action cannot be undone. Are you sure you want to continue?",
                primaryAction: AppSheetAction(title: "Confirm") {},
                secondaryAction: AppSheetAction(title: "Cancel") {}
            )
        }
}
#endif
