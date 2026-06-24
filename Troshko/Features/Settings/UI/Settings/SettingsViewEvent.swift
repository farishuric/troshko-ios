import Foundation
import MVVM

enum SettingsViewEvent: ViewEvent {
    case onAppear
    case appearanceSelected(AppAppearance)
    case languageSelected(AppLanguage)
    case signInWithAppleCompleted(SignInWithApplePayload)
    case signInWithAppleFailed
    case purchasePremium
    case restorePurchases
    case signOut
    case deleteAccount
    case seedDemoData
}
