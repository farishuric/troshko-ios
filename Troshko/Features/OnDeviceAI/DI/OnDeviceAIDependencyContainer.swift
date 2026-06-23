import DI
import Foundation

enum OnDeviceAIDependencyContainer {
    static func register() {
        DIContainer.shared.register(
            FoundationModelsOnDeviceAIRepository() as OnDeviceAIRepository,
            as: OnDeviceAIRepository.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardSuggestExpenseCategoryUseCase() as SuggestExpenseCategoryUseCase,
            as: SuggestExpenseCategoryUseCase.self,
            configuration: .shared
        )
        DIContainer.shared.register(
            StandardGenerateMonthlyInsightUseCase() as GenerateMonthlyInsightUseCase,
            as: GenerateMonthlyInsightUseCase.self,
            configuration: .shared
        )
    }
}
