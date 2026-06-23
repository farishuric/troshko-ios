import SwiftUI

/// Motion primitives for Troshko's **calm & fluid** design language.
///
/// Slow, gentle springs and soft fades — never snappy, never bouncy. Every screen
/// references these constants so timing stays consistent app-wide; don't invent
/// ad-hoc `.spring(...)` / `duration:` values at call sites.
///
/// **Reduce Motion:** all motion here is accessibility-aware. Read
/// `\.accessibilityReduceMotion` and pass it through `Motion.resolved(_:reduceMotion:)`,
/// or use the view modifiers in `Entrances.swift`, which already do this. When Reduce
/// Motion is on, springs/offsets collapse to a short cross-fade.
public enum Motion {

    // MARK: - Durations (seconds)

    public enum Duration {
        /// Near-instant feedback — taps, small state flips.
        public static let quick: TimeInterval = 0.25
        /// The standard calm transition — the default for most motion.
        public static let standard: TimeInterval = 0.5
        /// Slow ambient drift — banners and large surfaces settling in.
        public static let slow: TimeInterval = 0.7
    }

    // MARK: - Named animations (calm & fluid)

    /// The signature Troshko motion: a gentle spring with no overshoot.
    public static let calm = Animation.spring(response: Duration.standard, dampingFraction: 0.9, blendDuration: 0)

    /// Slow ambient drift for banners / large floating surfaces.
    public static let drift = Animation.spring(response: Duration.slow, dampingFraction: 0.95, blendDuration: 0)

    /// Soft symmetric fade for opacity-only changes.
    public static let fade = Animation.easeInOut(duration: Duration.standard)

    /// Quick ease for small immediate feedback.
    public static let quick = Animation.easeInOut(duration: Duration.quick)

    /// The amount a view rises into place during a calm entrance (8 pt).
    public static let entranceRise: CGFloat = Spacing.Semantic.componentMargin

    /// Per-item delay used to stagger a calm cascade in lists.
    public static let staggerStep: TimeInterval = 0.06

    /// Cap on the total stagger delay so long lists never feel slow.
    public static let staggerCap: TimeInterval = 0.36

    // MARK: - Reduce Motion

    /// Resolves an animation against the user's Reduce Motion setting: when Reduce
    /// Motion is on, any spring/offset motion collapses to a short cross-fade so
    /// nothing slides or springs.
    public static func resolved(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: Duration.quick) : animation
    }
}
