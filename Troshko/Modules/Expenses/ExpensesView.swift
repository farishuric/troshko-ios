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
    @ObservedObject var expensesVM = ExpensesViewModel(viewContext: CoreDataManager.shared.container.viewContext)
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(expensesVM.groupedExpenses) { group in
                            Section {
                                ForEach(group.expenses, id: \.self) { expense in
                                    ExpenseItemView(viewModel: expense)
//                                        .swipeActions(edge: .trailing) {
//                                            Button("WORDING_DELETE".localized) {
//                                                expensesVM.delete(expense: expense) {
//                                                    expensesVM.fetchExpenses()
//                                                }
//                                            }
//                                            .tint(.red)
//                                        }
                                    
                                        .swipeActions(edge: .leading) {
                                            Button("WORDING_EDIT".localized) {
                                                print("Awesome!")
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
                        if expensesVM.expenses.isEmpty {
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
            AddExpensesView(isPresented: $expensesVM.isPresentingAddExpenses)
                .onDisappear {
                    withAnimation {
                        expensesVM.fetchExpenses()
                    }
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
