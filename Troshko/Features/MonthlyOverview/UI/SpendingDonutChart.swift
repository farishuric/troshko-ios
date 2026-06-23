import SwiftUI
import Charts
import Styleguide

/// Per-category spending as a donut chart, built on Apple Swift Charts (replaces DGCharts).
struct SpendingDonutChart: View {
    let items: [CategorySpending]

    var body: some View {
        Chart(items) { item in
            SectorMark(
                angle: .value("MONTHLY_OVERVIEW.NAV_TITLE".localized, Double(item.total.amountMinor)),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(Spacing.Semantic.groupSpacing)
            .foregroundStyle(by: .value("CATEGORIES.TITLE".localized, item.categoryName))
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: Spacing.Semantic.itemSpacing)
        .aspectRatio(1, contentMode: .fit)
        .padding(Spacing.Semantic.screenMargin)
    }
}
