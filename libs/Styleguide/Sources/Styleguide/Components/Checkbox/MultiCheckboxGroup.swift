//
//
//  MultiCheckboxGroup.swift
//  Styleguide
//
//  Created by Fare
//
    


import SwiftUI

public struct MultiCheckboxGroup: View {
    private let items: [CheckboxItem]
    @Binding private var selectedIds: Set<String>
    private let onChange: (Set<String>) -> Void

    public init(
        items: [CheckboxItem],
        selectedIds: Binding<Set<String>>,
        onChange: @escaping (Set<String>) -> Void = { _ in }
    ) {
        self.items = items
        self._selectedIds = selectedIds
        self.onChange = onChange
    }

    public var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                CheckboxRow(
                    title: item.title,
                    isSelected: selectedIds.contains(item.id),
                    onTap: {
                        if selectedIds.contains(item.id) {
                            selectedIds.remove(item.id)
                        } else {
                            selectedIds.insert(item.id)
                        }
                        onChange(selectedIds)
                    }
                )
            }
        }
    }
}