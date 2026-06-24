import DI
import Foundation

enum AccountDependencyContainer {
    static func register() {
        let accountRepository = UserDefaultsAccountRepository() as AccountRepository
        let subscriptionRepository = StoreKitSubscriptionRepository() as SubscriptionRepository

        DIContainer.shared.register(
            accountRepository,
            as: AccountRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            subscriptionRepository,
            as: SubscriptionRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetAccountSessionUseCase(repository: accountRepository) as GetAccountSessionUseCase,
            as: GetAccountSessionUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardSignInWithAppleUseCase(repository: accountRepository) as SignInWithAppleUseCase,
            as: SignInWithAppleUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardSignOutUseCase(repository: accountRepository) as SignOutUseCase,
            as: SignOutUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardDeleteAccountUseCase(repository: accountRepository) as DeleteAccountUseCase,
            as: DeleteAccountUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardLoadSubscriptionProductsUseCase(repository: subscriptionRepository) as LoadSubscriptionProductsUseCase,
            as: LoadSubscriptionProductsUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGetPremiumEntitlementUseCase(repository: subscriptionRepository) as GetPremiumEntitlementUseCase,
            as: GetPremiumEntitlementUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardPurchasePremiumUseCase(repository: subscriptionRepository) as PurchasePremiumUseCase,
            as: PurchasePremiumUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardRestorePurchasesUseCase(repository: subscriptionRepository) as RestorePurchasesUseCase,
            as: RestorePurchasesUseCase.self,
            configuration: .shared
        )
    }
}

