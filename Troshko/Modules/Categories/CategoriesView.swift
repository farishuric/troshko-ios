//
//  CategoriesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct CategoriesView: View {
    var body: some View {
        VStack {
            NavigationView {
                Text("Hello \("CATEGORIES.TITLE".localized)")
                    .navigationTitle("EXPENSES.TITLE".localized)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemName: "plus")
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                        }
                    }
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
