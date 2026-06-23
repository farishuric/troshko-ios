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

    /// Styles a `List` row as a **floating frosted card** for the calm & fluid
    /// language: a translucent soft-shadowed surface with side margins, a gap to its
    /// neighbours, and no separator — rows read as individual cards floating over the
    /// ambient background instead of a flat grouped block.
    ///
    /// Use with `.listStyle(.plain)` + `.scrollContentBackground(.hidden)`, and give
    /// the row content no horizontal padding of its own (the insets here supply it).
    func floatingListRow() -> some View {
        let shape = RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusXXLarge, style: .continuous)
        return self
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: Spacing.Semantic.componentMargin,
                leading: Spacing.Semantic.screenMargin + Spacing.Semantic.componentPadding,
                bottom: Spacing.Semantic.componentMargin,
                trailing: Spacing.Semantic.screenMargin + Spacing.Semantic.componentPadding
            ))
            .listRowBackground(
                shape
                    .fill(SemanticColor.Colors.surfaceCard.swiftUIColor.opacity(0.78))
                    .background(.ultraThinMaterial, in: shape)
                    .overlay {
                        shape.strokeBorder(
                            SemanticColor.Colors.plainWhite.swiftUIColor.opacity(0.12),
                            lineWidth: Spacing.Semantic.borderWidth
                        )
                    }
                    .softShadow()
                    .padding(.horizontal, Spacing.Semantic.screenMargin)
                    .padding(.vertical, Spacing.Semantic.componentMargin / 2)
            )
    }
}
