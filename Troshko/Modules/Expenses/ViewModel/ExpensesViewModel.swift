//
//  ExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

/// View model for managing expenses.
class ExpensesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedCategory = 0
    @Published var categories: [Category] = []
    @Published var expenses: [Expense] = []
    @Published var isPresentingAddExpenses: Bool = false
    @Published var groupedExpenses: [GroupedExpenses] = []
    
    // MARK: - Properties
    
    /// Editing options
    @Published var isEditing: Bool = false
    var editingExpense: Expense? {
        didSet {
            title = editingExpense?.title ?? ""
            description = editingExpense?.desc ?? ""
            price = editingExpense?.price != nil ? "\(editingExpense!.price)" : ""
            selectedDate = editingExpense?.date ?? Date()
            if let category = editingExpense?.category {
                selectedCategory = categories.firstIndex(where: { category == $0 }) ?? 0
            }
        }
    }
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Form Fields
    
    @Published var title = ""
    @Published var description = ""
    @Published var price: String = ""
    @Published var selectedDate = Date()
    
    // MARK: - Price validation
    @Published var priceErrorState: ErrorState?
    
    func validatePrice() {
        if price.isEmpty {
            priceErrorState = .emptyField
        } else if !isValidFormat(price) {
            priceErrorState = .invalidFormat
        } else if isZeroPrice(price) {
            priceErrorState = .custom(message: "Price cannot be zero")
        } else {
            priceErrorState = nil
        }
    }
    
    private func isValidFormat(_ text: String) -> Bool {
        // Add your format validation logic here
        // Example: Ensure the input is a valid number
        return Double(text) != nil
    }
    
    private func isZeroPrice(_ text: String) -> Bool {
        if let price = Double(text), price == 0 {
            return true
        }
        return false
    }
    
    // MARK: - Computed Properties
    
    var isAddDisabled: Bool {
        return title.isEmpty || description.isEmpty || price.isEmpty
    }
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchCategories()
    }
    
    // MARK: - Public Methods
    
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
        if let groupIndex = groupedExpenses.firstIndex(where: { $0 == group }) {
            let expense = groupedExpenses[groupIndex].expenses[index]
            delete(expense: expense) {
                DispatchQueue.main.async {
                    self.groupedExpenses[groupIndex].expenses.removeAll { $0 == expense }
                    if self.groupedExpenses[groupIndex].expenses.isEmpty {
                        self.groupedExpenses.remove(at: groupIndex)
                    }
                }
            }
        }
    }
    
    func saveExpense(completion: @escaping () -> Void) {
        let category = categories[safe: selectedCategory]
        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.title = title
        newExpense.desc = description
        newExpense.price = price.toDouble()
        newExpense.date = selectedDate
        
        if !categories.isEmpty {
            newExpense.category = categories[selectedCategory]
        }
        
        if let category, editingExpense == nil {
            category.addToExpense(newExpense)
        }
        
        do {
            try viewContext.save()
            completion()
        } catch {
            print("Error saving expense")
        }
    }
    
    func editExpense(completion: @escaping () -> Void) {
        if let editingExpense {
            guard let id = editingExpense.id else { return }
            let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
            viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
            
            let results = try? viewContext.fetch(fetchRequest)
            
            if let editedExpense = results?.first {
                editedExpense.id = editingExpense.id
                editedExpense.title = title
                editedExpense.desc = description
                editedExpense.price = price.toDouble()
                editedExpense.date = selectedDate
                editedExpense.category = categories[selectedCategory]
                
                do {
                    try viewContext.save()
                    completion()
                } catch {
                    print("Error editing expense")
                }
            }
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
