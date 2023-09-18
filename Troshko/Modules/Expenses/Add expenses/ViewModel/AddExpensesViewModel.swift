//
//  AddExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation

class AddExpensesViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var price: CGFloat = 0.0
    @Published var selectedDate = Date()
}
