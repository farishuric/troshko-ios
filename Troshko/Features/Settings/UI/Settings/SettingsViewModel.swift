import Combine
import DI
import Foundation
import MVVM

@MainActor
final class SettingsViewModel: ViewModel {
    @Published private(set) var state: SettingsViewState

    private let eventSubject = PassthroughSubject<SettingsViewModelEvent, Never>()
    var eventPublisher: AnyPublisher<SettingsViewModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    @Injected private var getAppearance: GetAppearanceUseCase
    @Injected private var setAppearance: SetAppearanceUseCase
    @Injected private var getLanguage: GetLanguageUseCase
    @Injected private var setLanguage: SetLanguageUseCase
    @Injected private var getAccountSession: GetAccountSessionUseCase
    @Injected private var signInWithApple: SignInWithAppleUseCase
    @Injected private var signOut: SignOutUseCase
    @Injected private var deleteAccount: DeleteAccountUseCase
    @Injected private var loadSubscriptionProducts: LoadSubscriptionProductsUseCase
    @Injected private var getPremiumEntitlement: GetPremiumEntitlementUseCase
    @Injected private var purchasePremium: PurchasePremiumUseCase
    @Injected private var restorePurchases: RestorePurchasesUseCase
    @Injected private var seedDemoData: SeedDemoDataUseCase

    init() {
        self.state = SettingsViewModel.initialState()
    }

    func trigger(_ event: SettingsViewEvent) {
        switch event {
        case .onAppear:
            Task { await refresh() }
        case .appearanceSelected(let appearance):
            setAppearance.execute(appearance)
            state.appearance = appearance
        case .languageSelected(let language):
            setLanguage.execute(language)
            state.language = language
        case .signInWithAppleCompleted(let payload):
            Task { await handleSignIn(payload: payload) }
        case .signInWithAppleFailed:
            state.accountErrorMessage = "SETTINGS.ACCOUNT.ERROR_SIGN_IN".localized
        case .purchasePremium:
            Task { await handlePurchase() }
        case .restorePurchases:
            Task { await handleRestore() }
        case .signOut:
            Task { await handleSignOut() }
        case .deleteAccount:
            Task { await handleDeleteAccount() }
        case .seedDemoData:
            Task { await handleSeedDemoData() }
        }
    }

    private func refresh() async {
        state.isAccountLoading = true
        state.accountErrorMessage = nil
        state.subscriptionErrorMessage = nil

        let session = await getAccountSession.execute()
        let entitlement = await getPremiumEntitlement.execute()
        let products = (try? await loadSubscriptionProducts.execute()) ?? []

        state = SettingsViewState(
            appearance: getAppearance.execute(),
            appVersion: SettingsViewModel.currentAppVersion(),
            language: getLanguage.execute(),
            account: SettingsViewModel.accountState(from: session),
            subscription: SettingsViewModel.subscriptionState(
                from: entitlement,
                product: products.first
            ),
            isAccountLoading: false,
            isDemoDataLoading: false,
            accountErrorMessage: nil,
            subscriptionErrorMessage: nil,
            demoDataMessage: state.demoDataMessage
        )
    }

    private func handleSignIn(payload: SignInWithApplePayload) async {
        state.isAccountLoading = true
        state.accountErrorMessage = nil
        do {
            let session = try await signInWithApple.execute(payload: payload)
            state.account = SettingsViewModel.accountState(from: session)
        } catch {
            state.accountErrorMessage = "SETTINGS.ACCOUNT.ERROR_SIGN_IN".localized
        }
        state.isAccountLoading = false
    }

    private func handleSeedDemoData() async {
        state.isDemoDataLoading = true
        state.demoDataMessage = nil
        do {
            try await seedDemoData.execute()
            state.demoDataMessage = "SETTINGS.DEMO_DATA.SUCCESS".localized
        } catch {
            state.demoDataMessage = "SETTINGS.DEMO_DATA.ERROR".localized
        }
        state.isDemoDataLoading = false
    }

    private func handlePurchase() async {
        guard let productID = state.subscription.product?.id else {
            state.subscriptionErrorMessage = "SETTINGS.SUBSCRIPTION.ERROR_PRODUCT".localized
            return
        }

        state.isAccountLoading = true
        state.subscriptionErrorMessage = nil
        do {
            let entitlement = try await purchasePremium.execute(productID: productID)
            state.subscription = SettingsViewModel.subscriptionState(
                from: entitlement,
                product: state.subscription.product?.domainProduct
            )
        } catch {
            state.subscriptionErrorMessage = "SETTINGS.SUBSCRIPTION.ERROR_PURCHASE".localized
        }
        state.isAccountLoading = false
    }

    private func handleRestore() async {
        state.isAccountLoading = true
        state.subscriptionErrorMessage = nil
        do {
            let entitlement = try await restorePurchases.execute()
            state.subscription = SettingsViewModel.subscriptionState(
                from: entitlement,
                product: state.subscription.product?.domainProduct
            )
        } catch {
            state.subscriptionErrorMessage = "SETTINGS.SUBSCRIPTION.ERROR_RESTORE".localized
        }
        state.isAccountLoading = false
    }

    private func handleSignOut() async {
        state.isAccountLoading = true
        state.accountErrorMessage = nil
        do {
            try await signOut.execute()
            state.account = .signedOut
        } catch {
            state.accountErrorMessage = "SETTINGS.ACCOUNT.ERROR_SIGN_OUT".localized
        }
        state.isAccountLoading = false
    }

    private func handleDeleteAccount() async {
        state.isAccountLoading = true
        state.accountErrorMessage = nil
        do {
            try await deleteAccount.execute()
            state.account = .signedOut
        } catch {
            state.accountErrorMessage = "SETTINGS.ACCOUNT.ERROR_DELETE".localized
        }
        state.isAccountLoading = false
    }

    private static func initialState() -> SettingsViewState {
        SettingsViewState(
            appearance: .system,
            appVersion: SettingsViewModel.currentAppVersion(),
            language: AppLanguage.current,
            account: .signedOut,
            subscription: SettingsSubscriptionState(
                isPremiumActive: false,
                statusText: "SETTINGS.SUBSCRIPTION.INACTIVE".localized,
                product: nil
            ),
            isAccountLoading: false,
            isDemoDataLoading: false,
            accountErrorMessage: nil,
            subscriptionErrorMessage: nil,
            demoDataMessage: nil
        )
    }

    private static func accountState(from session: AccountSession?) -> SettingsAccountState {
        guard let session else { return .signedOut }
        let displayName = session.displayName ?? session.email ?? "SETTINGS.ACCOUNT.SIGNED_IN".localized
        return .signedIn(displayName: displayName, email: session.email)
    }

    private static func subscriptionState(
        from entitlement: PremiumEntitlement,
        product: SubscriptionProduct?
    ) -> SettingsSubscriptionState {
        SettingsSubscriptionState(
            isPremiumActive: entitlement.isActive,
            statusText: subscriptionStatusText(from: entitlement),
            product: product.map {
                SettingsSubscriptionProductState(
                    id: $0.id,
                    title: $0.displayName,
                    description: $0.description,
                    price: $0.displayPrice
                )
            }
        )
    }

    private static func subscriptionStatusText(from entitlement: PremiumEntitlement) -> String {
        guard entitlement.isActive else {
            return "SETTINGS.SUBSCRIPTION.INACTIVE".localized
        }

        guard let expirationDate = entitlement.expirationDate else {
            return "SETTINGS.SUBSCRIPTION.ACTIVE".localized
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = AppLanguage.current.locale
        let date = formatter.string(from: expirationDate)
        return String(format: "SETTINGS.SUBSCRIPTION.ACTIVE_UNTIL".localized, date)
    }

    private static func currentAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        switch (version, build) {
        case let (version?, build?):
            return "\(version) (\(build))"
        case let (version?, nil):
            return version
        default:
            return "WORDING_UNKNOWN".localized
        }
    }

}

private extension SettingsSubscriptionProductState {
    var domainProduct: SubscriptionProduct {
        SubscriptionProduct(
            id: id,
            displayName: title,
            description: description,
            displayPrice: price
        )
    }
}
