import SwiftUI

public struct BaseScreen<Content: View>: View {
    private let content: Content
    private let dismissesKeyboardOnTap: Bool
    private let isLoading: Bool
    private let minimumLoadingDuration: TimeInterval
    private let showsAmbientBackground: Bool

    @Environment(\.screenLoadingOverlay) private var loadingOverlay

    /// Keeps the loader on screen for the remainder of `minimumLoadingDuration`
    /// after `isLoading` has already dropped, so a fast backend can't flash it.
    /// Set to `true` *while* loading is still active (preemptively) so the moment
    /// `isLoading` flips false the loader stays continuously visible — no
    /// reveal-then-hide flicker on the trailing edge.
    @State private var isHoldingLoader = false
    @State private var loadingStartedAt: Date?

    public init(
        isLoading: Bool = false,
        minimumLoadingDuration: TimeInterval = 0.5,
        dismissesKeyboardOnTap: Bool = false,
        showsAmbientBackground: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.minimumLoadingDuration = minimumLoadingDuration
        self.dismissesKeyboardOnTap = dismissesKeyboardOnTap
        self.showsAmbientBackground = showsAmbientBackground
        self.content = content()
    }

    /// Derived synchronously from `isLoading` so the overlay is up in the *same*
    /// render pass the screen enters loading — there is no async gap where the
    /// content (e.g. a bottom-pinned button) can paint for a frame.
    private var isLoaderVisible: Bool { isLoading || isHoldingLoader }

    public var body: some View {
        if dismissesKeyboardOnTap {
            base.simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.dismissKeyboardUnlessFocusMoves()
                }
            )
        } else {
            base
        }
    }

    private var base: some View {
        ZStack {
            if showsAmbientBackground {
                AmbientGradientBackground()
            } else {
                SemanticColor.Colors.backgroundPrimary.swiftUIColor
                    .ignoresSafeArea()
            }

            // Content is always laid out at full size underneath; we only fade
            // it in. This avoids the layout "expanding from narrow" jank that
            // happens when a screen swaps a small spinner for full-width content.
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isLoaderVisible ? 0 : 1)

            if isLoaderVisible {
                loadingOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isLoaderVisible)
        // Anchor the minimum-duration clock to when the loader becomes visible on
        // *this* appearance. A persisted tab that re-appears already in a loading
        // state won't re-run `.task` (its `isLoading` id never changed), so the
        // clock must be (re)stamped here too.
        .onAppear {
            if isLoading {
                loadingStartedAt = Date()
                isHoldingLoader = true
            }
        }
        // `.task(id:)` cancels & restarts whenever `isLoading` flips, so a quick
        // loading→done→loading bounce never strands a pending reveal.
        .task(id: isLoading) {
            if isLoading {
                loadingStartedAt = Date()
                isHoldingLoader = true
                return
            }

            // Never entered loading on this screen → nothing to hold.
            guard let startedAt = loadingStartedAt else {
                isHoldingLoader = false
                return
            }

            // Loading just finished. If it finished sooner than the minimum, hold
            // the loader for the remainder; if it already ran longer, `remaining`
            // is non-positive and we reveal immediately — real latency is never
            // padded.
            let remaining = minimumLoadingDuration - Date().timeIntervalSince(startedAt)
            if remaining > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                guard !Task.isCancelled else { return }
            }
            isHoldingLoader = false
        }
    }
}

private extension UIApplication {
    func dismissKeyboardUnlessFocusMoves() {
        guard let firstResponder = keyWindow?.firstResponder else { return }

        DispatchQueue.main.async {
            guard firstResponder.isFirstResponder else { return }
            firstResponder.resignFirstResponder()
        }
    }

    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}

private extension UIView {
    var firstResponder: UIView? {
        if isFirstResponder {
            return self
        }

        return subviews.lazy.compactMap(\.firstResponder).first
    }
}
