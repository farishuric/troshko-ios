import Foundation

struct PremiumEntitlement: Equatable {
    let isActive: Bool
    let productID: String?
    let expirationDate: Date?

    static let inactive = PremiumEntitlement(
        isActive: false,
        productID: nil,
        expirationDate: nil
    )
}

enum PremiumSubscriptionConfiguration {
    static let yearlyProductID = "com.troshko.premium.yearly"
    static let productIDs: Set<String> = [yearlyProductID]
}

