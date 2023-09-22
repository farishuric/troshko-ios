//
//  MainView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct MainView: View {
    @StateObject var expensesVM = ExpensesViewModel(viewContext: CoreDataManager.shared.container.viewContext)
    
    var body: some View {
        TabView {
            ExpensesView()
                .environmentObject(expensesVM)
                .tabItem {
                    Label("EXPENSES.TITLE".localized, systemImage: "creditcard")
                }
            CategoriesView()
                .environmentObject(expensesVM)
                .tabItem {
                    Label("CATEGORIES.TITLE".localized, systemImage: "archivebox.fill")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
