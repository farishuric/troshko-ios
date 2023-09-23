//
//  ExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

class ExpensesViewModel: ObservableObject {
    
    @Published var selectedCategory = 0
    @Published var categories: [Category] = []
    
    @Published var expenses: [Expense] = []
    @Published var isPresentingAddExpenses: Bool = false
    
    @Published var groupedExpenses: [GroupedExpenses] = []
    
    var editingExpense: Expense? {
        didSet {
            title = editingExpense?.title ?? ""
            description = editingExpense?.desc ?? ""
            price = "\(editingExpense?.price ?? 0.0)"
            selectedDate = editingExpense?.date ?? Date()
        }
    }
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchCategories()
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
    
    @Published var title = ""
    @Published var description = ""
    @Published var price: String = ""
    @Published var selectedDate = Date()
    
    var isAddDisabled: Bool {
        return title.isEmpty || description.isEmpty || price.isEmpty
    }
    
    func saveExpense(completion: @escaping () -> Void) {
//        let category = categories[selectedCategory]
        let newExpense = Expense(context: viewContext)
        newExpense.title = title
        newExpense.desc = description
        newExpense.price = price.toFloat() ?? 0.0
        newExpense.date = selectedDate
        if !categories.isEmpty {
            newExpense.category = categories[selectedCategory]
        }
        
//        category.addToExpenses(newExpense)
        do {
            try viewContext.save()
            completion()
        } catch {
            print("Error saving expense")
        }
    }
    
    func fetchCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            categories = try viewContext.fetch(fetchRequest)
        } catch {
            print("Fetch failed")
        }
    }
}

struct GroupedExpenses: Identifiable, Equatable {
    var id: UUID = .init()
    var date: Date
    var expenses: [Expense]
    var formattedDate: String
}
