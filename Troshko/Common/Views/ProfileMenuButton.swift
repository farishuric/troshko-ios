import SwiftUI
import Styleguide

struct ProfileMenuButton: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Button(action: openSettings) {
            Image(systemName: "person.crop.circle")
                .font(.semibold(.large))
        }
        .tint(SemanticColor.Colors.primary.swiftUIColor)
        .accessibilityLabel(Text("SETTINGS.PROFILE.ACCESSIBILITY".localized))
    }
}
