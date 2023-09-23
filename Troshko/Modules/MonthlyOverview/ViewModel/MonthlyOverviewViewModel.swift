//
//  MonthlyOverviewViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import Foundation
import DGCharts
import CoreData

class MonthlyOverviewViewModel: ObservableObject {
    private var categories: [Category] = []
    init() {
        self.categories = fetchCategoriesWithExpenses()
        print(categories[0].expense)
    }
    private let managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.container.viewContext
    @Published var entries: [PieChartDataEntry] =  [
        PieChartDataEntry(value: 10, label: "Test"),
        PieChartDataEntry(value: 10.0, label: "Test2"),
        PieChartDataEntry(value: 60, label: "Test3"),
        PieChartDataEntry(value: 10, label: "Test4"),
        PieChartDataEntry(value: 10)
    ]
}

extension MonthlyOverviewViewModel {
    func fetchCategoriesWithExpenses() -> [Category] {
        let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryFetchRequest.relationshipKeyPathsForPrefetching = ["expenses"]

        do {
            let categories = try managedObjectContext.fetch(categoryFetchRequest)
            return categories
        } catch {
            print("Error fetching categories and expenses: \(error.localizedDescription)")
            return []
        }
    }
}
