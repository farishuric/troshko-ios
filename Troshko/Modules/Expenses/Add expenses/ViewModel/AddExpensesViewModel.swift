//
//  AddExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

class AddExpensesViewModel: ObservableObject {
    @Published var title = "Test"
    @Published var description = "Test"
    @Published var price: String = "1"
    @Published var selectedDate = Date()
    
    var isAddDisabled: Bool {
        return title.isEmpty || description.isEmpty || price.isEmpty
    }
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func saveExpense(completion: @escaping () -> Void) {
        let newExpense = Expense(context: viewContext)
        newExpense.title = title
        newExpense.desc = description
        newExpense.price = price.toFloat() ?? 0.0
        newExpense.date = selectedDate
        do {
            try viewContext.save()
            completion()
        } catch {
            print("Error saving expense")
        }
    }
}
