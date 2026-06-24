import Foundation

protocol SubscriptionRepository {
    func products() async throws -> [SubscriptionProduct]
    func currentEntitlement() async -> PremiumEntitlement
    func purchase(productID: String) async throws -> PremiumEntitlement
    func restorePurchases() async throws -> PremiumEntitlement
}

