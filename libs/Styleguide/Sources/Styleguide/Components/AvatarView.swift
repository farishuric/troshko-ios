import SwiftUI

/// Reusable circular gradient avatar with initials. Floats with a soft shadow and a
/// thin white ring — no hard border. Optionally shows a green "online" dot.
public struct AvatarView: View {
    private let initials: String
    private let size: CGFloat
    private let showsOnlineDot: Bool

    public init(initials: String, size: CGFloat = 64, showsOnlineDot: Bool = false) {
        self.initials = initials
        self.size = size
        self.showsOnlineDot = showsOnlineDot
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            SemanticColor.Colors.secondary.swiftUIColor,
                            SemanticColor.Colors.primary.swiftUIColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Circle().strokeBorder(
                        SemanticColor.Colors.plainWhite.swiftUIColor.opacity(0.6),
                        lineWidth: size * 0.05
                    )
                }

            Text(initials)
                .font(.bold(size > 48 ? .large : .body))
                .foregroundStyle(SemanticColor.Colors.plainWhite.swiftUIColor)
        }
        .frame(width: size, height: size)
        .softShadow()
        .overlay(alignment: .bottomTrailing) {
            if showsOnlineDot {
                Circle()
                    .fill(SemanticColor.Colors.success.swiftUIColor)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .overlay {
                        Circle().strokeBorder(
                            SemanticColor.Colors.plainWhite.swiftUIColor,
                            lineWidth: size * 0.045
                        )
                    }
                    .offset(x: -size * 0.03, y: -size * 0.03)
            }
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        AvatarView(initials: "JD", showsOnlineDot: true)
        AvatarView(initials: "AB", size: 44)
    }
    .padding(40)
}

#Preview("Dark") {
    HStack(spacing: 24) {
        AvatarView(initials: "JD", showsOnlineDot: true)
        AvatarView(initials: "AB", size: 44)
    }
    .padding(40)
    .preferredColorScheme(.dark)
}
