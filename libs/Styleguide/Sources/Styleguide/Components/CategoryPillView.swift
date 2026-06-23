import SwiftUI

public struct CategoryPillView: View {
    let title: String
    let icon: String?

    public init(title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.regular(.small))
            }
            Text(title)
                .font(.semibold(.small))
        }
        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(SemanticColor.Colors.primary.swiftUIColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        CategoryPillView(title: "TACTILE")
        CategoryPillView(title: "AUDITORY", icon: "ear")
        CategoryPillView(title: "VISUAL", icon: "eye")
    }
    .padding()
}
#endif
