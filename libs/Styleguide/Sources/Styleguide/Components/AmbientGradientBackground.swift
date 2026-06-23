import SwiftUI

/// Barely-perceptible ambient backdrop for the soft-floating wellness UI: an
/// off-white base with a cyan glow drifting in from the top-right and a pale blue
/// glow from the bottom-left. Glows are very low opacity and heavily blurred so the
/// user should barely notice them. Non-interactive; place at the back of a `ZStack`
/// (or let `BaseScreen(showsAmbientBackground: true)` install it for you).
public struct AmbientGradientBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            SemanticColor.Colors.backgroundPrimary.swiftUIColor

            GeometryReader { geo in
                let side = max(geo.size.width, geo.size.height)

                Ellipse()
                    .fill(SemanticColor.Colors.ambientGlowCyan.swiftUIColor)
                    .frame(width: side * 1.1, height: side * 1.1)
                    .opacity(0.16)
                    .blur(radius: 100)
                    .position(x: geo.size.width * 0.92, y: geo.size.height * 0.08)

                Ellipse()
                    .fill(SemanticColor.Colors.ambientGlowBlue.swiftUIColor)
                    .frame(width: side * 1.2, height: side * 1.2)
                    .opacity(0.12)
                    .blur(radius: 110)
                    .position(x: geo.size.width * 0.06, y: geo.size.height * 0.96)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    AmbientGradientBackground()
}

#Preview("Dark") {
    AmbientGradientBackground()
        .preferredColorScheme(.dark)
}
