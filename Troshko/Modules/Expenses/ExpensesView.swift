//
//  ExpensesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct TestModel: Hashable {
    var title: String
    var desc: String
    var price: String
}

struct ExpensesView: View {
    @EnvironmentObject var expensesVM: ExpensesViewModel
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(expensesVM.groupedExpenses) { group in
                        Section {
                            ForEach(group.expenses, id: \.self) { expense in
                                ExpenseItemView(viewModel: expense)
                                    .swipeActions(edge: .leading) {
                                        Button("WORDING_EDIT".localized) {
                                            expensesVM.editingExpense = expense
                                            expensesVM.isEditing = true
                                            expensesVM.isPresentingAddExpenses = true
                                        }
                                        .tint(.blue)
                                    }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    expensesVM.deleteFromGroup(at: index, in: group)
                                }
                            }
                        } header: {
                            Text(group.formattedDate)
                        }
                        
                    }
                }
                .overlay {
                    if expensesVM.expenses.isEmpty || expensesVM.groupedExpenses.isEmpty {
                        EmptyStateView(systemImage: "doc.text", text: "EXPENSES.NO_EXPENSES".localized)
                    }
                }
            }
        }
        .sheet(isPresented: $expensesVM.isPresentingAddExpenses) {
            expensesVM.isPresentingAddExpenses = false
        } content: {
            AddExpensesView()
                .environmentObject(expensesVM)
                .onDisappear {
                    expensesVM.fetchExpenses()
                    expensesVM.editingExpense = nil
                    expensesVM.isEditing = false
                }
        }
        .onAppear {
            withAnimation {
                expensesVM.fetchExpenses()
            }
        }
        .onChange(of: expensesVM.selectedDate) { value1, value2 in
            print("Value 1 \(value1)")
            print("Value 2 \(value2)")
        }
    }
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
