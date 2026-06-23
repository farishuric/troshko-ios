import Foundation

/// Canonical money value used across Domain, Data mapping, and UI display.
/// Stores exact integer minor units plus the ISO 4217 currency code.
struct Money: Equatable, Hashable, Sendable {
    let amountMinor: Int
    let currencyCode: String

    init(amountMinor: Int, currencyCode: String = Self.deviceCurrencyCode) {
        self.amountMinor = amountMinor
        self.currencyCode = currencyCode
    }

    static var deviceCurrencyCode: String {
        Locale.current.currency?.identifier ?? "BAM"
    }

    static func zero(currencyCode: String = Self.deviceCurrencyCode) -> Money {
        Money(amountMinor: 0, currencyCode: currencyCode)
    }

    static func +(lhs: Money, rhs: Money) -> Money {
        lhs.adding(rhs)
    }

    func adding(_ other: Money) -> Money {
        precondition(currencyCode == other.currencyCode, "Cannot add amounts with different currencies")
        return Money(amountMinor: amountMinor + other.amountMinor, currencyCode: currencyCode)
    }

    func formatted(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = Self.minorUnitDigits(for: currencyCode)
        formatter.maximumFractionDigits = Self.minorUnitDigits(for: currencyCode)

        let majorAmount = Decimal(amountMinor) / Decimal(Self.minorUnitScale(for: currencyCode))
        return formatter.string(from: NSDecimalNumber(decimal: majorAmount)) ?? "\(amountMinor) \(currencyCode)"
    }

    func inputText(locale: Locale = .current) -> String {
        let scale = Self.minorUnitScale(for: currencyCode)
        let digits = Self.minorUnitDigits(for: currencyCode)
        let separator = locale.decimalSeparator ?? "."
        let sign = amountMinor < 0 ? "-" : ""
        let absoluteMinor = abs(amountMinor)
        let major = absoluteMinor / scale
        let fraction = absoluteMinor % scale

        guard digits > 0 else { return "\(sign)\(major)" }

        let fractionText = String(fraction).leftPadded(toLength: digits, with: "0")
        return "\(sign)\(major)\(separator)\(fractionText)"
    }

    static func parse(
        _ text: String,
        currencyCode: String = Self.deviceCurrencyCode,
        locale: Locale = .current
    ) -> Money? {
        let digits = minorUnitDigits(for: currencyCode)
        let scale = minorUnitScale(for: currencyCode)
        let decimalSeparator = locale.decimalSeparator ?? "."
        let groupingSeparator = locale.groupingSeparator ?? ","

        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        value = value.replacingOccurrences(of: currencyCode, with: "", options: [.caseInsensitive])
        value = value.replacingOccurrences(
            of: currencySymbol(for: currencyCode, locale: locale),
            with: "",
            options: [.caseInsensitive]
        )
        value = value.filter { !$0.isWhitespace && $0 != "\u{00a0}" }

        guard !value.isEmpty, !value.hasPrefix("-") else { return nil }

        let parts = value.components(separatedBy: decimalSeparator)
        guard parts.count <= 2 else { return nil }

        guard let major = parseMajorUnits(parts[0], groupingSeparator: groupingSeparator) else {
            return nil
        }

        let fractionText = parts.count == 2 ? parts[1] : ""
        guard fractionText.count <= digits, isDigits(fractionText) else { return nil }

        let paddedFraction = fractionText.leftPadded(toLength: digits, with: "0", fromRight: true)
        let fraction = Int(paddedFraction.isEmpty ? "0" : paddedFraction) ?? 0

        guard major <= (Int.max - fraction) / scale else { return nil }

        return Money(amountMinor: major * scale + fraction, currencyCode: currencyCode)
    }

    static func currencySymbol(for currencyCode: String, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.currencySymbol ?? currencyCode
    }

    static func minorUnitScale(for currencyCode: String) -> Int {
        let digits = minorUnitDigits(for: currencyCode)
        return (0..<digits).reduce(1) { scale, _ in scale * 10 }
    }

    static func minorUnitDigits(for currencyCode: String) -> Int {
        switch currencyCode.uppercased() {
        case "BIF", "CLP", "DJF", "GNF", "ISK", "JPY", "KMF", "KRW", "PYG", "RWF", "UGX", "VND", "VUV", "XAF", "XOF", "XPF":
            return 0
        case "BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND":
            return 3
        default:
            return 2
        }
    }

    private static func parseMajorUnits(_ text: String, groupingSeparator: String) -> Int? {
        guard !text.isEmpty else { return 0 }

        if text.contains(groupingSeparator) {
            let groups = text.components(separatedBy: groupingSeparator)
            guard
                let first = groups.first,
                (1...3).contains(first.count),
                isDigits(first),
                groups.dropFirst().allSatisfy({ $0.count == 3 && isDigits($0) })
            else { return nil }

            return Int(groups.joined())
        }

        guard isDigits(text) else { return nil }
        return Int(text)
    }

    private static func isDigits(_ text: String) -> Bool {
        text.allSatisfy { $0.wholeNumberValue != nil }
    }
}

private extension String {
    func leftPadded(toLength length: Int, with pad: Character, fromRight: Bool = false) -> String {
        guard count < length else { return self }
        let padding = String(repeating: String(pad), count: length - count)
        return fromRight ? self + padding : padding + self
    }
}
