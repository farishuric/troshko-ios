//
//  GroupedExpenses.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import Foundation

// Legacy support type for the not-yet-migrated Categories / MonthlyOverview screens
// (Phase 2). Backed by the Core Data `LegacyExpense`. Removed in Phase 3.
struct GroupedExpenses: Identifiable, Equatable {
    var id: UUID = .init()
    var date: Date
    var expenses: [LegacyExpense]
    var formattedDate: String
}
