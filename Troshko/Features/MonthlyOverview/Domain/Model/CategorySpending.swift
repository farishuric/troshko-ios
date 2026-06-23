import Foundation

/// Total amount spent in one category over a given period. Drives the overview chart.
struct CategorySpending: Identifiable, Equatable, Hashable {
    var id: String { categoryName }
    let categoryName: String
    let total: Money
}
