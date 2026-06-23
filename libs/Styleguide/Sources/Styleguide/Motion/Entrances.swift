import SwiftUI

// MARK: - Calm entrance

public extension View {
    /// Calm entrance: the view fades in and rises a few points into place the first
    /// time it appears — the signature on-load motion of the floating language.
    ///
    /// Pass `index` to stagger a gentle cascade in a list (each item starts slightly
    /// later, capped so long lists never drag). Honors Reduce Motion: the rise is
    /// dropped and the cascade collapses to a single soft fade.
    func softAppear(index: Int = 0) -> some View {
        modifier(SoftAppearModifier(index: index))
    }
}

/// Drives the fade + rise entrance. State is per-view, so it plays once when the
/// view first mounts.
public struct SoftAppearModifier: ViewModifier {
    private let index: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    public init(index: Int = 0) {
        self.index = index
    }

    public func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: (appeared || reduceMotion) ? 0 : Motion.entranceRise)
            .onAppear {
                let delay = reduceMotion
                    ? 0
                    : min(Double(index) * Motion.staggerStep, Motion.staggerCap)
                withAnimation(Motion.resolved(Motion.calm, reduceMotion: reduceMotion).delay(delay)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Calm transition

public extension AnyTransition {
    /// Calm insertion/removal: a soft fade combined with a gentle vertical drift.
    /// Use for content that swaps in/out (e.g. a state change) so it never snaps.
    static var calm: AnyTransition {
        .opacity.combined(with: .offset(y: Motion.entranceRise))
    }
}
