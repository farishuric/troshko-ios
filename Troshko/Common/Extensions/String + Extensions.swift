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
    
    func toDouble(locale: Locale = Locale.current) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .decimal
        
        guard let number = numberFormatter.number(from: self) else {
            return 0.0
        }
        
        return number.doubleValue
    }
}
