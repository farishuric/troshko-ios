import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

final class FoundationModelsOnDeviceAIRepository: OnDeviceAIRepository {
    func suggestCategory(
        title: String,
        details: String,
        amount: Money?,
        date: Date,
        categories: [ExpenseCategory]
    ) async throws -> ExpenseCategorySuggestion? {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty, !categories.isEmpty else { return nil }

#if canImport(FoundationModels)
        let prompt = categoryPrompt(
            title: cleanTitle,
            details: details,
            amount: amount,
            date: date,
            categories: categories
        )

        do {
            let session = LanguageModelSession(
                instructions: """
                You suggest one expense category from a provided list. Respond with only the exact category name.
                If no category clearly fits, respond with NONE. Do not invent categories.
                """
            )
            let response = try await session.respond(to: prompt)
            return Self.matchCategory(named: response.content, in: categories).map {
                ExpenseCategorySuggestion(category: $0, confidence: .medium, reason: nil)
            }
        } catch {
            throw OnDeviceAIError.unavailable
        }
#else
        throw OnDeviceAIError.unavailable
#endif
    }

    func generateMonthlyInsight(context: MonthlyInsightContext, month: Date) async throws -> MonthlyInsight? {
#if canImport(FoundationModels)
        let prompt = monthlyInsightPrompt(context: context, month: month)

        do {
            let session = LanguageModelSession(
                instructions: """
                You write short, careful personal-finance insights. Use only the numbers provided.
                Do not calculate new numbers. Do not call it financial advice.
                Return two lines: first a short title, second one helpful sentence.
                """
            )
            let response = try await session.respond(to: prompt)
            return Self.parseInsight(response.content)
        } catch {
            throw OnDeviceAIError.unavailable
        }
#else
        throw OnDeviceAIError.unavailable
#endif
    }

    private func categoryPrompt(
        title: String,
        details: String,
        amount: Money?,
        date: Date,
        categories: [ExpenseCategory]
    ) -> String {
        let categoryNames = categories.map(\.name).joined(separator: ", ")
        let amountText = amount?.formatted() ?? "unknown"

        return """
        Expense title: \(title)
        Details: \(details.trimmingCharacters(in: .whitespacesAndNewlines))
        Amount: \(amountText)
        Date: \(Self.dateFormatter.string(from: date))
        Categories: \(categoryNames)

        Pick the best existing category.
        """
    }

    private func monthlyInsightPrompt(context: MonthlyInsightContext, month: Date) -> String {
        let goalLine: String
        if let goalName = context.savingsGoalName, let monthlyTarget = context.monthlyTarget {
            goalLine = "Savings goal: \(goalName), monthly target \(monthlyTarget.formatted())."
        } else {
            goalLine = "Savings goal: none set."
        }

        return """
        Month: \(Self.monthFormatter.string(from: month))
        Income this month: \(context.income.formatted())
        Spent this month: \(context.expenses.formatted())
        Saved this month: \(context.saved.formatted())
        \(goalLine)

        Write one calm, useful insight for the Home screen.
        """
    }

    private static func matchCategory(named rawName: String, in categories: [ExpenseCategory]) -> ExpenseCategory? {
        let normalized = normalize(rawName)
        guard normalized != "none" else { return nil }

        return categories.first { normalize($0.name) == normalized }
            ?? categories.first { normalized.contains(normalize($0.name)) }
    }

    private static func parseInsight(_ content: String) -> MonthlyInsight? {
        let lines = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard let first = lines.first else { return nil }

        let title = first.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let message = lines.dropFirst().joined(separator: " ")
        guard !title.isEmpty, !message.isEmpty else { return nil }

        return MonthlyInsight(title: title, message: message)
    }

    private static func normalize(_ text: String) -> String {
        text
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            .lowercased()
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
}
