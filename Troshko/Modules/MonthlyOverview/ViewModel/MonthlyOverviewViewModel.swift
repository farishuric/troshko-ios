//
//  MonthlyOverviewViewModel.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import Foundation
import DGCharts
import CoreData

/// View model for the monthly overview screen.
class MonthlyOverviewViewModel: ObservableObject {
    // MARK: - Properties
    
    /// The list of categories.
    private var categories: [Category] = []
    
    /// The list of monthly overview models.
    private var models: [MonthlyOverviewModel] = [] {
        didSet {
            totalExpenses = countTotalMonthExpenses(from: models)
            entries = mapChartData(from: models)
        }
    }
    
    /// The Core Data managed object context.
    private let managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.container.viewContext
    
    /// The pie chart data entries.
    @Published var entries: [PieChartDataEntry] = []
    
    /// The selected date for the monthly overview.
    @Published var selectedDate = Date()
    
    /// The selected month.
    @Published var selectedMonth = 0
    
    /// The selected year.
    @Published var selectedYear = 0
    
    /// The total expenses for the selected month.
    @Published var totalExpenses: Float = 0
    
    /// A flag indicating whether the date picker is presented.
    @Published var isPickerPresented = false
    
    // MARK: - Initializers
    
    /// Initializes the view model.
    init() {
        fetchCategoriesWithExpenses(for: Date())
    }
}

// MARK: - Public Methods

extension MonthlyOverviewViewModel {
    /// Fetches categories with expenses for the given date.
    func fetchCategoriesWithExpenses(for date: Date) {
        models = []
        categories = []
        entries = []
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth!)
        
        let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryFetchRequest.relationshipKeyPathsForPrefetching = ["expenses"]
        
        var models: [MonthlyOverviewModel] = []
        var currentTotalPrice: Float = 0.0
        
        do {
            let categories = try managedObjectContext.fetch(categoryFetchRequest)
            
            for category in categories {
                if let expenses = category.expense {
                    let expenseArray = expenses.array as! [Expense]
                    let filteredExpenses = expenseArray.filter { (expense) -> Bool in
                        if let expenseDate = expense.date {
                            return expenseDate >= startOfMonth! && expenseDate <= endOfMonth!
                        }
                        return false
                    }
                    
                    for expense in filteredExpenses {
                        currentTotalPrice += expense.price
                    }
                }
                if currentTotalPrice > 0 {
                    models.append(MonthlyOverviewModel(categoryName: category.name ?? "WORDING_UNKNOWN".localized, totalExpenses: currentTotalPrice))
                }
                currentTotalPrice = 0
            }
            self.models = models
        } catch {
            print("Error fetching categories and expenses: \(error.localizedDescription)")
        }
    }
    
    /// Maps monthly overview model data to pie chart data entries.
    func mapChartData(from expenses: [MonthlyOverviewModel]) -> [PieChartDataEntry] {
        expenses.compactMap {
            return PieChartDataEntry(value: Double($0.totalExpenses), label: $0.categoryName)
        }
    }
    
    /// Counts the total expenses for the selected month.
    func countTotalMonthExpenses(from models: [MonthlyOverviewModel]) -> Float {
        var totalExpense: Float = 0
        models.forEach { totalExpense += $0.totalExpenses }
        return totalExpense
    }
}
