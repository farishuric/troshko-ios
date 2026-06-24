import Foundation
import MVVM

struct SettingsViewState: ViewState, Equatable {
    var appearance: AppAppearance
    var appVersion: String
    var language: AppLanguage
    var account: SettingsAccountState
    var subscription: SettingsSubscriptionState
    var isAccountLoading: Bool
    var isDemoDataLoading: Bool
    var accountErrorMessage: String?
    var subscriptionErrorMessage: String?
    var demoDataMessage: String?
}

enum SettingsAccountState: Equatable {
    case signedOut
    case signedIn(displayName: String, email: String?)
}

struct SettingsSubscriptionState: Equatable {
    var isPremiumActive: Bool
    var statusText: String
    var product: SettingsSubscriptionProductState?
}

struct SettingsSubscriptionProductState: Equatable, Identifiable {
    let id: String
    let title: String
    let description: String
    let price: String
}
