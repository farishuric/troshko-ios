import Foundation

protocol LoadSubscriptionProductsUseCase {
    func execute() async throws -> [SubscriptionProduct]
}

struct StandardLoadSubscriptionProductsUseCase: LoadSubscriptionProductsUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute() async throws -> [SubscriptionProduct] {
        try await repository.products()
    }
}

