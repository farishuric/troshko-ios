//
//  MainView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            // Migrated to Clean Architecture (Phase 1). Owns its own ViewModel via DI.
            ExpensesView(vm: ExpensesViewModel())
                .tabItem {
                    Label("EXPENSES.TITLE".localized, systemImage: "creditcard")
                }
            // Migrated to Clean Architecture + SwiftData (Phase 2). Own their ViewModels via DI.
            CategoriesView(vm: CategoriesViewModel())
                .tabItem {
                    Label("CATEGORIES.TITLE".localized, systemImage: "archivebox.fill")
                }
            MonthlyOverviewView(vm: MonthlyOverviewViewModel())
                .tabItem {
                    Label("MONTHLY_OVERVIEW.TITLE".localized, systemImage: "chart.pie")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
