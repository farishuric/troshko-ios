//
//
//  CheckboxRow.swift
//  Styleguide
//
//  Created by Fare
//
    


import SwiftUI

public struct CheckboxRow: View {
    private let title: String
    private let isSelected: Bool
    private let onTap: () -> Void

    public init(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(
                        isSelected ? SemanticColor.Colors.primary.swiftUIColor : SemanticColor.Colors.borderPrimary.swiftUIColor
                    )
            }
            .padding()
            .background(SemanticColor.Colors.textFieldBG.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusLarge))
            
        }
        .buttonStyle(.plain)
    }
}
