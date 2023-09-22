//
//  AddExpensesViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation
import CoreData

class AddExpensesViewModel: ObservableObject {
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
}
