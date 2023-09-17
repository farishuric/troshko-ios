//
//  ExpensesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct ExpensesView: View {
    var body: some View {
        VStack {
            NavigationView {
                Text("Hello \("EXPENSES.TITLE".localized)")
                    .navigationTitle("EXPENSES.TITLE".localized)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Label("", systemImage: "plus")
                                .foregroundColor(.blue)
                        }
                    }
            }
        }
        
    }
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
