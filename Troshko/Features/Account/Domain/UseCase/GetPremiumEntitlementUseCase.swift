import Foundation

protocol GetPremiumEntitlementUseCase {
    func execute() async -> PremiumEntitlement
}

struct StandardGetPremiumEntitlementUseCase: GetPremiumEntitlementUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute() async -> PremiumEntitlement {
        await repository.currentEntitlement()
    }
}

