import Foundation
import DI

protocol GenerateMonthlyInsightUseCase {
    func execute(context: MonthlyInsightContext, month: Date) async throws -> MonthlyInsight?
}

final class StandardGenerateMonthlyInsightUseCase: GenerateMonthlyInsightUseCase {
    @Injected private var repository: OnDeviceAIRepository

    func execute(context: MonthlyInsightContext, month: Date) async throws -> MonthlyInsight? {
        try await repository.generateMonthlyInsight(context: context, month: month)
    }
}
