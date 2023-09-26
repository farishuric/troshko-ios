//
//  Double+Extensions.swift
//  Troshko
//
//  Created by Faris Hurić on 26. 9. 2023..
//

import Foundation

extension Double {
    static let numberToStringFormatter = NumberFormatter()
    func toString(
        decimal: Int = 0,
        usesGroupingSeparator: Bool = true,
        locale: Locale = Locale.current,
        lessThanZeroDecimals: Int = 16
    ) -> String {
        let formatter = Double.numberToStringFormatter
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = decimal
        if self < 1 {
            formatter.maximumFractionDigits = lessThanZeroDecimals
        } else {
            formatter.maximumFractionDigits = 6
        }
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.paddingCharacter = "0"
        formatter.locale = locale
        formatter.usesGroupingSeparator = usesGroupingSeparator
        return String(formatter.string(from: number)?.trimmed ?? "")
    }
}
