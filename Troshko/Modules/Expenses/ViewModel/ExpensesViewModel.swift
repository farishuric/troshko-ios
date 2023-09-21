//
//  ExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

import Foundation
import CoreData

class ExpensesViewModel: ObservableObject {
    
    @Published var expenses: [Expense] = []
    @Published var isPresentingAddExpenses: Bool = false
    
    @Published var groupedExpenses: [GroupedExpenses] = []
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func fetchExpenses() {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            expenses = try viewContext.fetch(fetchRequest)
            groupedExpenses = groupExpensesByDate(expenses: expenses)
        } catch {
            print("Fetch failed")
        }
    }
    
    func delete(expense: Expense, completion: @escaping () -> Void) {
        viewContext.delete(expense)
        do {
            try viewContext.save()
            completion()
        } catch {
            print("Error deleting")
        }
    }

    func groupExpensesByDate(expenses: [Expense]) -> [GroupedExpenses] {
        var groupedExpenses: [GroupedExpenses] = []

        // Create a DateFormatter to format the dates for grouping
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy" // Month Year format

        // Get today's date and current month
        let currentDate = Date()
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentYear = Calendar.current.component(.year, from: currentDate)

        for expense in expenses {
            if let expenseDate = expense.date {
                var groupedExpense: GroupedExpenses
                let expenseMonth = Calendar.current.component(.month, from: expenseDate)
                let expenseYear = Calendar.current.component(.year, from: expenseDate)

                if Calendar.current.isDate(expenseDate, inSameDayAs: currentDate) {
                    groupedExpense = GroupedExpenses(date: expenseDate, expenses: [], formattedDate: "Today")
                } else if currentMonth == expenseMonth && currentYear == expenseYear {
                    groupedExpense = GroupedExpenses(date: expenseDate, expenses: [], formattedDate: "This Month")
                } else {
                    let formattedDate = dateFormatter.string(from: expenseDate)
                    groupedExpense = GroupedExpenses(date: expenseDate, expenses: [], formattedDate: formattedDate)
                }

                // Check if a grouped expense with the same date already exists
                if let existingIndex = groupedExpenses.firstIndex(where: { $0.formattedDate == groupedExpense.formattedDate }) {
                    groupedExpenses[existingIndex].expenses.append(expense)
                } else {
                    groupedExpense.expenses.append(expense)
                    groupedExpenses.append(groupedExpense)
                }
            }
        }

        return groupedExpenses
    }
    
    func deleteFromGroup(at index: Int, in group: GroupedExpenses) {
        let group = groupedExpenses.firstIndex {
            $0 == group
        }
        
        
        if let group {
            let expense = groupedExpenses[group].expenses[index]
            delete(expense: expense) {
                DispatchQueue.main.async {
                    self.groupedExpenses[group].expenses.removeAll { $0 == expense }
                    if self.groupedExpenses[group].expenses.isEmpty {
                        self.groupedExpenses.remove(at: group)
                    }
                }
            }
        }   
    }
}

struct GroupedExpenses: Identifiable, Equatable {
    var id: UUID = .init()
    var date: Date
    var expenses: [Expense]
    var formattedDate: String
}