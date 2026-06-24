import Foundation
import StoreKit

enum StoreKitSubscriptionError: Error {
    case productNotFound
    case purchaseCancelled
    case purchasePending
    case unverifiedTransaction
}

final class StoreKitSubscriptionRepository: SubscriptionRepository {
    private let productIDs: Set<String>
    private var cachedProducts: [Product] = []

    init(productIDs: Set<String> = PremiumSubscriptionConfiguration.productIDs) {
        self.productIDs = productIDs
    }

    func products() async throws -> [SubscriptionProduct] {
        let products = try await loadStoreProducts()
        return products.map {
            SubscriptionProduct(
                id: $0.id,
                displayName: $0.displayName,
                description: $0.description,
                displayPrice: $0.displayPrice
            )
        }
    }

    func currentEntitlement() async -> PremiumEntitlement {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  productIDs.contains(transaction.productID) else {
                continue
            }

            return PremiumEntitlement(
                isActive: true,
                productID: transaction.productID,
                expirationDate: transaction.expirationDate
            )
        }

        return .inactive
    }

    func purchase(productID: String) async throws -> PremiumEntitlement {
        let product = try await product(for: productID)
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try verifiedTransaction(from: verification)
            await transaction.finish()
            return await currentEntitlement()
        case .userCancelled:
            throw StoreKitSubscriptionError.purchaseCancelled
        case .pending:
            throw StoreKitSubscriptionError.purchasePending
        @unknown default:
            return await currentEntitlement()
        }
    }

    func restorePurchases() async throws -> PremiumEntitlement {
        try await AppStore.sync()
        return await currentEntitlement()
    }

    private func product(for productID: String) async throws -> Product {
        if let cached = cachedProducts.first(where: { $0.id == productID }) {
            return cached
        }

        let products = try await loadStoreProducts()
        guard let product = products.first(where: { $0.id == productID }) else {
            throw StoreKitSubscriptionError.productNotFound
        }
        return product
    }

    private func loadStoreProducts() async throws -> [Product] {
        if !cachedProducts.isEmpty {
            return cachedProducts
        }

        let products = try await Product.products(for: Array(productIDs))
            .sorted { $0.displayName < $1.displayName }
        cachedProducts = products
        return products
    }

    private func verifiedTransaction(
        from result: VerificationResult<Transaction>
    ) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw StoreKitSubscriptionError.unverifiedTransaction
        }
    }
}

