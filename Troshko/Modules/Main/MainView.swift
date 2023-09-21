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
            ExpensesView()
                .tabItem {
                    Label("EXPENSES.TITLE".localized, systemImage: "creditcard")
                }
            CategoriesView()
                .tabItem {
                    Label("CATEGORIES.TITLE".localized, systemImage: "archivebox.fill")
                }
        }
        .onAppear {
            whereIsMySQLite()
        }
    }
    
    func whereIsMySQLite() {
            let path = FileManager
                .default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .last?
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
                .removingPercentEncoding

            print(path ?? "Not found")
        }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
