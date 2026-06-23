//
//  Expense+CoreDataProperties.swift
//  Troshko
//
//  Created by Faris Hurić on 26. 9. 2023..
//
//

import Foundation
import CoreData

extension LegacyExpense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegacyExpense> {
        return NSFetchRequest<LegacyExpense>(entityName: "Expense")
    }

    @NSManaged public var date: Date?
    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var price: Double
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}

extension LegacyExpense: Identifiable {

}
