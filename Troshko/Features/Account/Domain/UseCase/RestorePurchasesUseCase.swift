import Foundation

protocol RestorePurchasesUseCase {
    func execute() async throws -> PremiumEntitlement
}

struct StandardRestorePurchasesUseCase: RestorePurchasesUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute() async throws -> PremiumEntitlement {
        try await repository.restorePurchases()
    }
}

