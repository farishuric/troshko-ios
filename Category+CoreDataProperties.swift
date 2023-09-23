//
//  Category+CoreDataProperties.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//
//

import Foundation
import CoreData

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var expense: Expense?

}

extension Category: Identifiable {

}

extension Category {

    @objc(addUsersObject:)
    @NSManaged public func addToExpenses(_ value: Expense)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromExpenses(_ value: Expense)

    @objc(addUsers:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}
