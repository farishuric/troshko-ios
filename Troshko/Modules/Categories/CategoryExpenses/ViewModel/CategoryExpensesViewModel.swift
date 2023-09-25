//
//  CategoryExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 25. 9. 2023..
//

import SwiftUI
import CoreData

final class CategoryExpensesViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var groupedExpenses: [GroupedExpenses] = []
    
    let viewContext = CoreDataManager.shared.container.viewContext
    
    func fetchCategory(categoryName: String) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "name == %@", categoryName)
        
        fetchRequest.predicate = predicate
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if let category = result.first {
                if let expenses = category.expense?.array as? [Expense] {
                    self.expenses = expenses
                    self.groupedExpenses = groupExpensesByDate(expenses: expenses)
                }
            }
        } catch {
            print("Error fetching category")
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
                    groupedExpense = GroupedExpenses(date: expenseDate, expenses: [], formattedDate: "CALENDAR_TODAY".localized)
                } else if currentMonth == expenseMonth && currentYear == expenseYear {
                    groupedExpense = GroupedExpenses(date: expenseDate, expenses: [], formattedDate: "CALENDAR_THIS_MONTH".localized)
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
}
