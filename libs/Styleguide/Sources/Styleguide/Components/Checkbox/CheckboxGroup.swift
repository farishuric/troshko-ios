//
//
//  CheckboxGroup.swift
//  Styleguide
//
//  Created by Fare
//
    


import SwiftUI

public struct CheckboxGroup: View {
    private let items: [CheckboxItem]
    @Binding private var selectedId: String?
    private let onChange: (String?) -> Void

    public init(
        items: [CheckboxItem],
        selectedId: Binding<String?>,
        onChange: @escaping (String?) -> Void = { _ in }
    ) {
        self.items = items
        self._selectedId = selectedId
        self.onChange = onChange
    }

    public var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                CheckboxRow(
                    title: item.title,
                    isSelected: selectedId == item.id,
                    onTap: {
                        if selectedId == item.id {
                            selectedId = nil
                        } else {
                            selectedId = item.id
                        }
                        onChange(selectedId)
                    }
                )
            }
        }
    }
}