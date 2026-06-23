import SwiftUI
import Styleguide

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "creditcard.fill")
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                .frame(
                    width: Spacing.Semantic.minimumTouchTarget,
                    height: Spacing.Semantic.minimumTouchTarget
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: Spacing.Semantic.cornerRadiusLarge,
                        style: .continuous
                    )
                    .fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                Text(expense.title)
                    .font(.semibold(.body))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    .lineLimit(1)

                if !expense.details.isEmpty {
                    Text(expense.details)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        .lineLimit(1)
                }

                Text(expense.date, format: .dateTime.day().month().year())
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
            }

            Spacer(minLength: Spacing.Semantic.componentMargin)

            VStack(alignment: .trailing, spacing: Spacing.Semantic.groupSpacing) {
                Text(expense.amount.formatted())
                    .font(.semibold(.large))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

                if let category = expense.category {
                    Text(category.name)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                        .padding(.horizontal, Spacing.Semantic.groupSpacing)
                        .padding(.vertical, Spacing.Semantic.componentMargin / 2)
                        .background(
                            Capsule().fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.12))
                        )
                }
            }
        }
        .padding(.vertical, Spacing.Semantic.componentMargin)
    }
}
