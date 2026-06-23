//
//  Expense+CoreDataClass.swift
//  Troshko
//
//  Created by Faris Hurić on 26. 9. 2023..
//
//

import Foundation
import CoreData

// Renamed from `Expense` to `LegacyExpense` during the Clean Architecture migration
// (Phase 1) so the new Domain `Expense` struct can own the canonical name. This
// Core Data entity is still used by Categories + MonthlyOverview until they migrate
// (Phase 2); the whole Core Data stack is removed in Phase 3. The model entity is
// still named "Expense" — only the backing class name changed.
@objc(LegacyExpense)
public class LegacyExpense: NSManagedObject {

}
