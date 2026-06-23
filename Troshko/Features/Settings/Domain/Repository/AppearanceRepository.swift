import Foundation

protocol AppearanceRepository {
    func getAppearance() -> AppAppearance
    func setAppearance(_ appearance: AppAppearance)
}
