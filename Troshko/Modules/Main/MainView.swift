//
//  MainView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct MainView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(.white)
    }
    var body: some View {
        TabView {
            ExpensesView()
                .tabItem {
                    Label("EXPENSES.TITLE".localized, systemImage: "creditcard")
                }
            CategoriesView()
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
