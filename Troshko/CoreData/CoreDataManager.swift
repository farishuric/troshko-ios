//
//  CoreDataManager.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import Foundation

import CoreData
import Foundation

/// Main data manager to handle the todo items
class CoreDataManager: NSObject, ObservableObject {
    
    static let shared = CoreDataManager()
    
    /// Add the Core Data container with the model name
    let container: NSPersistentContainer = NSPersistentContainer(name: "TroshkoData")
    
    /// Default init method. Load the Core Data container
    override init() {
        super.init()
        container.loadPersistentStores { _, _ in }
    }
}
