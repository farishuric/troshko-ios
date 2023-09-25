//
//  CategoryExpensesView.swift
//  Troshko
//
//  Created by Faris Hurić on 25. 9. 2023..
//

import SwiftUI

struct CategoryExpensesView: View {
    var categoryName: String
    @ObservedObject var viewModel = CategoryExpensesViewModel()
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.groupedExpenses) { group in
                    Section {
                        ForEach(group.expenses, id: \.self) { expense in
                            ExpenseItemView(viewModel: expense)
                        }
                    } header: {
                        Text(group.formattedDate)
                    }
                    
                }
            }
            .overlay {
                if viewModel.expenses.isEmpty || viewModel.groupedExpenses.isEmpty {
                    EmptyStateView(systemImage: "doc.text", text: "EXPENSES.NO_EXPENSES".localized)
                }
            }
        }
        .onAppear {
            viewModel.fetchCategory(categoryName: categoryName)
        }
    }
}

struct CategoryExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryExpensesView(categoryName: "Test")
    }
}
