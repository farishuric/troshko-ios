//
//
//  CheckboxItem.swift
//  Styleguide
//
//  Created by Fare
//
    


public struct CheckboxItem: Identifiable, Hashable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}