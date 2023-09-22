//
//  Category+CoreDataProperties.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
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

}

extension Category: Identifiable {

}
