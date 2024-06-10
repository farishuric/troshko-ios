//
//  Collection+Extensions.swift
//  Troshko
//
//  Created by Faris Hurić on 7. 6. 2024..
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
