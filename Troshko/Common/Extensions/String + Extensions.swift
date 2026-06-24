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
        let value = AppLanguage.current.bundle.localizedString(forKey: self, value: nil, table: nil)
        guard value != self else {
            return AppLanguage.fallback.bundle.localizedString(forKey: self, value: self, table: nil)
        }
        return value
    }
    
    func localized(arguments: CVarArg...) -> String {
        return String(format: self.localized, locale: AppLanguage.current.locale, arguments: arguments)
    }
    
    func toFloat() -> Float {
        return Float(self) ?? 0.0
    }
    
}
