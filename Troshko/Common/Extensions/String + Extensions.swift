//
//  String + Extensions.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import Foundation

extension String {
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
    func toFloat() -> Float {
        return Float(self) ?? 0.0
    }
    
}
