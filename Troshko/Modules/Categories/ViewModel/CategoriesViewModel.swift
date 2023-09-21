//
//  CategoriesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

class CategoriesViewModel: ObservableObject {
    @Published var isShowingAlert: Bool = false
    @Published var categoryName: String = ""
    
    @Published var categories: [Category] = []
    
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
        isShowingAlert = false
        categoryName = ""
    }
    
    func delete(category: Category) {
        viewContext.delete(category)
        do {
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
