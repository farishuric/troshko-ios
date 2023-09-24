//
//  GroupedExpenses.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import Foundation

struct GroupedExpenses: Identifiable, Equatable {
    var id: UUID = .init()
    var date: Date
    var expenses: [Expense]
    var formattedDate: String
}
