//
//  Expense+CoreDataProperties.swift
//  Troshko
//
//  Created by Faris Hurić on 26. 9. 2023..
//
//

import Foundation
import CoreData

extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var date: Date?
    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var price: Double
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}

extension Expense: Identifiable {

}
