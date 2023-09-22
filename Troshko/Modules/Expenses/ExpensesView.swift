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
        VStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(expensesVM.groupedExpenses) { group in
                            Section {
                                ForEach(group.expenses, id: \.self) { expense in
                                    ExpenseItemView(viewModel: expense)
                                        .swipeActions(edge: .leading) {
                                            Button("WORDING_EDIT".localized) {
                                                expensesVM.editingExpense = expense
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
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                
                                Text("No expenses found")
                            }
                        }
                    }
                }
                .navigationTitle("EXPENSES.TITLE".localized)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            expensesVM.isPresentingAddExpenses.toggle()
                        } label: {
                            Label("", systemImage: "plus")
                        }
                        
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
                }
        }
        .onAppear {
            withAnimation {
                expensesVM.fetchExpenses()
            }
        }
    }
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
