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
    @NSManaged public var expense: NSOrderedSet?

}

// MARK: Generated accessors for expense
extension Category {

    @objc(insertObject:inExpenseAtIndex:)
    @NSManaged public func insertIntoExpense(_ value: Expense, at idx: Int)

    @objc(removeObjectFromExpenseAtIndex:)
    @NSManaged public func removeFromExpense(at idx: Int)

    @objc(insertExpense:atIndexes:)
    @NSManaged public func insertIntoExpense(_ values: [Expense], at indexes: NSIndexSet)

    @objc(removeExpenseAtIndexes:)
    @NSManaged public func removeFromExpense(at indexes: NSIndexSet)

    @objc(replaceObjectInExpenseAtIndex:withObject:)
    @NSManaged public func replaceExpense(at idx: Int, with value: Expense)

    @objc(replaceExpenseAtIndexes:withExpense:)
    @NSManaged public func replaceExpense(at indexes: NSIndexSet, with values: [Expense])

    @objc(addExpenseObject:)
    @NSManaged public func addToExpense(_ value: Expense)

    @objc(removeExpenseObject:)
    @NSManaged public func removeFromExpense(_ value: Expense)

    @objc(addExpense:)
    @NSManaged public func addToExpense(_ values: NSOrderedSet)

    @objc(removeExpense:)
    @NSManaged public func removeFromExpense(_ values: NSOrderedSet)

}

extension Category: Identifiable {

}
