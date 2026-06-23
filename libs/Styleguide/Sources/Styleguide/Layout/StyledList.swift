import SwiftUI

public extension View {
    /// Suppresses the system List background and applies `backgroundPrimary`
    /// as the scroll area colour (dark/light mode adaptive via asset catalog).
    func styledList() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(SemanticColor.Colors.listBackground.swiftUIColor)
    }

    /// Applies the list row background (dark/light mode adaptive).
    /// Apply this to a `Section` or individual row inside a `List`.
    func styledListRow() -> some View {
        self.listRowBackground(SemanticColor.Colors.listRow.swiftUIColor)
    }
}
