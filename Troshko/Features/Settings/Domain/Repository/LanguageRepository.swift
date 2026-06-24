import Foundation

protocol LanguageRepository {
    func getLanguage() -> AppLanguage
    func setLanguage(_ language: AppLanguage)
}
