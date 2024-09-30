//
//  CategoriesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

class CategoriesViewModel: ObservableObject {
    @Published var isShowingAddCategoryView: Bool = false
    @Published var categoryName: String = ""
    
    @Published var categories: [Category] = []
    
    @Published var isShowingDeletionAlert: Bool = false
    
    var categoryToDelete: Category?
    
    var isAddDisabled: Bool {
        return categoryName.isEmpty
    }
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchCategories()
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
    
    func saveCategory() {
        let newCategory = Category(context: viewContext)
        newCategory.name = categoryName
        newCategory.createdAt = Date()
        try? viewContext.save()
        isShowingAddCategoryView = false
        categoryName = ""
    }
    
    func delete(category: Category, completion: @escaping () -> Void) {
        // Fetch all expenses associated with the category
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            let categoryExpenses = try viewContext.fetch(fetchRequest)
            
            for expense in categoryExpenses {
                viewContext.delete(expense)
            }

            viewContext.delete(category)
            
            try viewContext.save()

            if let index = categories.firstIndex(where: { $0 == category }) {
                DispatchQueue.main.async {
                    self.categories.remove(at: index)
                }
            }
        } catch {
            print("Error deleting")
        }
    }

}
