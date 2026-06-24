import Foundation

protocol PurchasePremiumUseCase {
    func execute(productID: String) async throws -> PremiumEntitlement
}

struct StandardPurchasePremiumUseCase: PurchasePremiumUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute(productID: String) async throws -> PremiumEntitlement {
        try await repository.purchase(productID: productID)
    }
}

